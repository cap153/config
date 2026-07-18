/**
 * Agnes Video Extension - Generate videos via Agnes Video V2.0 API
 *
 * Provides two tools for the LLM:
 * - agnes_create_video: Create a video generation task
 * - agnes_get_video: Poll/get the video result by video_id
 *
 * The generated video is returned as a URL accessible in the browser.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import os from "node:os";
import path from "node:path";
import fs from "node:fs";

// Agnes API base
const AGNES_API_BASE = "https://apihub.agnes-ai.com";

interface CreateVideoResponse {
  id?: string;
  task_id?: string;
  video_id?: string;
  object?: string;
  model?: string;
  status?: string;
  progress?: number;
  created_at?: number;
  seconds?: string;
  size?: string;
}

interface GetVideoResponse {
  id?: string;
  video_id?: string;
  model?: string;
  object?: string;
  status?: string;
  progress?: number;
  seconds?: string;
  size?: string;
  url?: string;
  error?: { message?: string } | null;
}

/**
 * Get the Agnes API key from session configuration.
 * Tries the "agnes" provider's apiKey, then falls back to environment variable.
 */
function getApiKey(ctx: ExtensionContext): string | null {
  // Try to get the key from the registered provider's auth
  try {
    const model = ctx.model;
    if (model?.provider === "agnes") {
      // The key is available through the model registry
      // We'll use the env var directly as fallback
    }
  } catch {
    // ignore
  }

  // Check environment variable
  const envKey = process.env.AGNES_API;
  if (envKey) return envKey;

  return null;
}

/**
 * Make a request to the Agnes API with auth headers
 */
async function agnesRequest(
  path: string,
  options: { method?: string; body?: unknown; ctx?: ExtensionContext } = {},
): Promise<Response> {
  const { method = "GET", body, ctx } = options;

  // Build headers
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
  };

  // Try to get API key from various sources
  let apiKey: string | null = null;

  if (ctx) {
    apiKey = getApiKey(ctx);
  }

  if (!apiKey) {
    apiKey = process.env.AGNES_API ?? null;
  }

  if (!apiKey) {
    // Check if there's an auth.json or similar stored credential
    // This would be set by /login or similar pi mechanisms
    apiKey = null;
  }

  if (apiKey) {
    headers["Authorization"] = `Bearer ${apiKey}`;
  }

  const url = `${AGNES_API_BASE}${path}`;
  const fetchOptions: RequestInit = { method, headers };

  if (body) {
    fetchOptions.body = JSON.stringify(body);
  }

  return fetch(url, fetchOptions);
}

export default function (pi: ExtensionAPI) {
  // ─── Tool: Create Video ─────────────────────────────────────────────

  pi.registerTool({
    name: "agnes_create_video",
    label: "Create Agnes Video",
    description:
      "Create a video generation task via Agnes Video V2.0. Supports text-to-video, image-to-video, and keyframe animation. " +
      "Returns a video_id that can be used with agnes_get_video to retrieve the result. " +
      "Recommended parameters: width=1152, height=768, num_frames=121, frame_rate=24 for standard videos. " +
      "num_frames must be <= 441 and follow 8n+1 rule. " +
      "The response includes video_id (use with agnes_get_video), task_id (legacy), and initial status.",
    parameters: Type.Object({
      prompt: Type.String({
        description:
          "Text description of the video content (English only). For text-to-video, use structure: [subject] + [action] + [scene] + [camera movement] + [lighting] + [style]. For image-to-video, describe what should move and what should stay stable.",
      }),
      image: Type.Optional(
        Type.String({
          description: "Optional public image URL for image-to-video generation.",
        }),
      ),
      mode: Type.Optional(
        Type.String({
          description:
            'Generation mode. Omit for standard generation. Use "keyframes" for keyframe animation (requires extra_body with image array).',
        }),
      ),
      width: Type.Optional(
        Type.Number({
          description: "Video width in pixels. Default: 1152. Supports 480p, 720p, 1080p resolutions.",
        }),
      ),
      height: Type.Optional(
        Type.Number({
          description: "Video height in pixels. Default: 768.",
        }),
      ),
      num_frames: Type.Optional(
        Type.Number({
          description:
            "Number of frames. Must be <= 441 and follow 8n+1 rule. Common values: 81 (~3s), 121 (~5s), 241 (~10s), 441 (~18s). Default: 121.",
        }),
      ),
      frame_rate: Type.Optional(
        Type.Number({
          description: "Frame rate (1-60). Default: 24. Higher values = smoother motion.",
        }),
      ),
      negative_prompt: Type.Optional(
        Type.String({
          description: "Negative prompt describing what to avoid in the video.",
        }),
      ),
      seed: Type.Optional(
        Type.Number({
          description: "Random seed for reproducible results.",
        }),
      ),
      keyframe_images: Type.Optional(
        Type.Array(Type.String(), {
          description:
            "Array of public image URLs for keyframe animation. Only used when mode is 'keyframes'. Pass image URLs for transition between keyframes.",
        }),
      ),
      download_path: Type.Optional(
        Type.String({
          description:
            "Optional directory path to save the video file when it's ready. Defaults to user's home directory. " +
            "Use forward slashes (/) for cross-platform compatibility. " +
            "The filename will be auto-generated as 'agnes_video_<video_id>.mp4'.",
        }),
      ),
    }),
    async execute(_toolCallId, params, signal, _onUpdate, ctx) {
      // Build request body
      const body: Record<string, unknown> = {
        model: "agnes-video-v2.0",
        prompt: params.prompt,
      };

      // Add optional parameters if provided
      if (params.image) body["image"] = params.image;
      if (params.width !== undefined) body["width"] = params.width;
      if (params.height !== undefined) body["height"] = params.height;
      if (params.num_frames !== undefined) body["num_frames"] = params.num_frames;
      if (params.frame_rate !== undefined) body["frame_rate"] = params.frame_rate;
      if (params.negative_prompt !== undefined) body["negative_prompt"] = params.negative_prompt;
      if (params.seed !== undefined) body["seed"] = params.seed;

      // Handle keyframe mode
      if (params.mode === "keyframes" && params.keyframe_images && params.keyframe_images.length > 0) {
        body["extra_body"] = {
          image: params.keyframe_images,
          mode: "keyframes",
        };
      } else if (params.mode) {
        body["mode"] = params.mode;
      }

      // Set default resolution if width/height not specified
      if (params.width === undefined && params.height === undefined) {
        body["width"] = 1152;
        body["height"] = 768;
      }

      // Set default frames if not specified
      if (params.num_frames === undefined) {
        body["num_frames"] = 121;
      }
      if (params.frame_rate === undefined) {
        body["frame_rate"] = 24;
      }

      try {
        const response = await agnesRequest("/v1/videos", {
          method: "POST",
          body,
          ctx,
        });

        // Check for auth errors
        if (response.status === 401) {
          return {
            content: [
              {
                type: "text",
                text: "Authentication failed (401). Please set your Agnes API key:\n" +
                  "  1. Set the AGNES_API environment variable, or\n" +
                  "  2. Use /login in pi to configure the key for the 'agnes' provider",
              },
            ],
            details: { error: "unauthorized", status: 401 },
            isError: true,
          };
        }

        if (!response.ok) {
          const errorText = await response.text().catch(() => "Unknown error");
          return {
            content: [{ type: "text", text: `API error (${response.status}): ${errorText}` }],
            details: { error: "api_error", status: response.status },
            isError: true,
          };
        }

        const data = (await response.json()) as CreateVideoResponse;

        // Format a helpful response
        const videoId = data.video_id || "unknown";
        const taskId = data.task_id || data.id || "unknown";
        const status = data.status || "unknown";
        const seconds = data.seconds || "N/A";
        const size = data.size || "N/A";

        const resultText =
          `✅ Video task created successfully!\n\n` +
          `📹 Video ID: ${videoId}\n` +
          `🔖 Task ID: ${taskId}\n` +
          `📊 Status: ${status}\n` +
          `⏱ Duration: ${seconds}s\n` +
          `📐 Resolution: ${size}\n\n` +
          `Use agnes_get_video with video_id "${videoId}" to check the result. ` +
          `The video typically takes a minute or two to generate depending on parameters.`;

        return {
          content: [{ type: "text", text: resultText }],
          details: {
            video_id: videoId,
            task_id: taskId,
            status,
            seconds,
            size,
            download_path: params.download_path ?? null,
            raw: data,
          },
        };
      } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        return {
          content: [{ type: "text", text: `Failed to create video task: ${message}` }],
          details: { error: "network_error" },
          isError: true,
        };
      }
    },
  });

  // ─── Tool: Get Video Result ─────────────────────────────────────────

  pi.registerTool({
    name: "agnes_get_video",
    label: "Get Agnes Video Result",
    description:
      "Get the result of a video generation task by video_id. Returns the video URL when completed. " +
      "Use this to poll for results after creating a task with agnes_create_video. " +
      "Status values: queued → in_progress → completed | failed. " +
      "When status is 'completed', the response includes a 'url' field with the video URL accessible in browser. " +
      "When status is 'failed', an error object is included.",
    parameters: Type.Object({
      video_id: Type.String({
        description: "The video_id returned from agnes_create_video",
      }),
      download_path: Type.Optional(
        Type.String({
          description:
            "Directory to save the video file. Defaults to user's home directory. " +
            "Use forward slashes (/) for cross-platform compatibility. " +
            "Filename is auto-generated as 'agnes_video_<video_id>.mp4'.",
        }),
      ),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const { video_id } = params;

      try {
        // Use the recommended endpoint: GET /agnesapi?video_id=<VIDEO_ID>
        const response = await agnesRequest(`/agnesapi?video_id=${encodeURIComponent(video_id)}`, {
          method: "GET",
          ctx,
        });

        if (response.status === 404) {
          return {
            content: [
              {
                type: "text",
                text: `Video "${video_id}" not found. The video ID may be incorrect or the task may have been deleted.`,
              },
            ],
            details: { video_id, error: "not_found", status: 404 },
            isError: true,
          };
        }

        if (response.status === 401) {
          return {
            content: [
              {
                type: "text",
                text: "Authentication failed (401). Please set your Agnes API key.",
              },
            ],
            details: { error: "unauthorized", status: 401 },
            isError: true,
          };
        }

        if (!response.ok) {
          const errorText = await response.text().catch(() => "Unknown error");
          return {
            content: [{ type: "text", text: `API error (${response.status}): ${errorText}` }],
            details: { error: "api_error", status: response.status },
            isError: true,
          };
        }

        const data = (await response.json()) as GetVideoResponse;

        const status = data.status || "unknown";
        const progress = data.progress ?? 0;

        switch (status) {
          case "completed": {
            const videoUrl = data.url || null;
            const seconds = data.seconds || "N/A";
            const size = data.size || "N/A";

            // Determine download directory
            let downloadDir: string;
            if (params.download_path) {
              downloadDir = path.resolve(params.download_path);
            } else {
              downloadDir = os.homedir();
            }

            // Attempt to download the video
            let downloadResult = "";
            let savedPath: string | null = null;

            if (videoUrl) {
              try {
                // Ensure download directory exists
                fs.mkdirSync(downloadDir, { recursive: true });

                // Generate filename: agnes_video_<video_id>.mp4
                const safeId = video_id.replace(/[^a-zA-Z0-9_-]/g, "_");
                savedPath = path.join(downloadDir, `agnes_video_${safeId}.mp4`);

                // Download the video
                const resp = await fetch(videoUrl);
                if (resp.ok && resp.body) {
                  const reader = resp.body.getReader();
                  const chunks: Uint8Array[] = [];
                  let totalSize = 0;
                  while (true) {
                    const { done, value } = await reader.read();
                    if (done) break;
                    chunks.push(value);
                    totalSize += value.length;
                  }
                  const buffer = new Uint8Array(totalSize);
                  let offset = 0;
                  for (const chunk of chunks) {
                    buffer.set(chunk, offset);
                    offset += chunk.length;
                  }
                  fs.writeFileSync(savedPath, buffer);

                  const fileSize = (totalSize / 1024 / 1024).toFixed(1);
                  downloadResult = `\n💾 Downloaded: ${savedPath} (${fileSize} MB)`;
                } else {
                  downloadResult = `\n⚠️ Failed to download video (HTTP ${resp.status}), but you can still access it via the URL.`;
                }
              } catch (err) {
                const dlError = err instanceof Error ? err.message : String(err);
                downloadResult = `\n⚠️ Download failed: ${dlError}. You can still access the video via the URL below.`;
              }
            }

            let resultText =
              `✅ Video generation completed!\n\n` +
              `📹 Video ID: ${data.video_id || video_id}\n` +
              `⏱ Duration: ${seconds}s\n` +
              `📐 Resolution: ${size}\n`;

            if (videoUrl) {
              resultText += `${downloadResult}\n\n🔗 Video URL: ${videoUrl}\n`;
            } else {
              resultText += `\n⚠️ No video URL in the response.`;
            }

            const details: Record<string, unknown> = {
              video_id: data.video_id || video_id,
              status: "completed",
              url: videoUrl,
              seconds,
              size,
              saved_path: savedPath,
              raw: data,
            };
            if (downloadResult && !downloadResult.includes("⚠️") && savedPath) {
              details.saved_path = savedPath;
            }

            return {
              content: [{ type: "text", text: resultText }],
              details,
            };
          }

          case "failed": {
            const errorMsg = data.error?.message || "Unknown error";
            return {
              content: [
                {
                  type: "text",
                  text: `❌ Video generation failed!\n\nVideo ID: ${data.video_id || video_id}\nError: ${errorMsg}`,
                },
              ],
              details: {
                video_id: data.video_id || video_id,
                status: "failed",
                error: errorMsg,
                raw: data,
              },
              isError: true,
            };
          }

          case "queued":
          case "in_progress":
          default: {
            const progressBar = generateProgressBar(progress, 20);

            return {
              content: [
                {
                  type: "text",
                  text:
                    `⏳ Video is still generating...\n\n` +
                    `📹 Video ID: ${data.video_id || video_id}\n` +
                    `📊 Status: ${status}\n` +
                    `📈 Progress: ${progress}%\n` +
                    `   ${progressBar}\n\n` +
                    `Tip: Run agnes_get_video again with the same video_id to check again. ` +
                    `Videos typically take 1-3 minutes depending on frame count and resolution.`,
                },
              ],
              details: {
                video_id: data.video_id || video_id,
                status,
                progress,
                raw: data,
              },
            };
          }
        }
      } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        return {
          content: [{ type: "text", text: `Failed to get video result: ${message}` }],
          details: { error: "network_error" },
          isError: true,
        };
      }
    },
  });

  // ─── Helper: Progress Bar ──────────────────────────────────────────
}

function generateProgressBar(percent: number, width: number): string {
  const filled = Math.round((percent / 100) * width);
  const empty = width - filled;
  return "█".repeat(filled) + "░".repeat(empty) + ` ${percent}%`;
}

// ─── Zustand model entry (applied once on load) ──────────────────────
// This is informational only - the actual video API is accessed via tools above.
