-- ~/.config/yazi/plugins/max-preview.yazi/init.lua
return {
  entry = function()
    if state.old then
      Manager.layout, state.old = state.old, nil
    else
      state.old = Manager.layout
      Manager.layout = function(self, area)
        self.area = area

        return ui.Layout()
          :direction(ui.Layout.HORIZONTAL)
          :constraints({
            ui.Constraint.Percentage(0),
            ui.Constraint.Percentage(0),
            ui.Constraint.Percentage(100),
          })
          :split(area)
      end
    end
    ya.app_emit("resize", {})
  end,
}
