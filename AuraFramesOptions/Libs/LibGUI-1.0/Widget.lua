local LibGUI = LibStub("LibGUI-1.0");


function LibGUI:NewWidgetPrototype(Type, Version)
  
  local WidgetPrototype = {};
  
  setmetatable(WidgetPrototype, { __index = self.WidgetPrototype});
  
  WidgetPrototype.Type = Type;
  WidgetPrototype.Version = Version;
  
  self.WidgetPrototypes[Type] = WidgetPrototype;
  self.Pool[Type] = self.Pool[Type] or {};
  
  return WidgetPrototype;

end


function LibGUI:NewWidget(Type)

  if not self.WidgetPrototypes[Type] then
    return;
  end

  local Widget = {};
  
  setmetatable(Widget, { __index = self.WidgetPrototypes[Type]});
  
  Widget:Constructor();
  
  return Widget;

end
