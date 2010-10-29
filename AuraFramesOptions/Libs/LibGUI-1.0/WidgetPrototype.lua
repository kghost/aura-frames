local LibGUI = LibStub("LibGUI-1.0");


LibGUI.WidgetPrototype = LibGUI.Prototype or {};


function LibGUI.WidgetPrototype:SetWidth(Width)

  self.Frame:SetWidth(Width);

end

function LibGUI.WidgetPrototype:SetHeight(Height)

  self.Frame:SetHeight(Height);

end

function LibGUI.WidgetPrototype:Release()

  self:OnRelease();

  if self.Frame then
    self.Frame:ClearAllPoints();
    self.Frame:Hide();
  end

  table.insert(LibGUI.Pool[self.Type], self);

end

