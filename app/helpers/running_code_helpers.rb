module RunningCodeHelpers

  def reset
    children = @container.get_children
    (children.reduce([]) { |acc, child|
       acc << child unless child.get_id == 'default_canvas'; acc}
    ).each { |child| children.remove(child)}
  end

  def alert(caption, message)
    alert = Alert.new(Alert::AlertType::INFORMATION, message)
    alert.header_text = caption
    alert.show
  end

  def alert_and_wait(caption, message)
    alert = Alert.new(Alert::AlertType::INFORMATION, message, ButtonType::CANCEL, ButtonType::OK)
    alert.header_text = caption
    result = false
    alert.show_and_wait
    .filter { |response| response == ButtonType::OK }
    .if_present { |response| result = true}
    result
  end

  def control_add(control)
    @container.get_children.add(control)
    @container.applyCss
    @container.layout
    bounds = control.get_bounds_in_parent
    control.width = bounds.get_width
    control.height = bounds.get_height
  end

  def button_create(text, opts, &block)
    params = {
      :x => 0,
      :y => 0
    }.deep_merge(opts)
    c = Button.new(text)
    c.relocate(params[:x], params[:y])
    p block_given?
    c.set_on_action(block) if block_given?
    control_add(c)
    c
  end

  def label_create(text, opts = {}, &action)
    params = {
      :x => 0,
      :y => 0
    }.deep_merge(opts)
    c = Label.new(text)
    c.relocate(params[:x], params[:y])
    c.set_on_action(action) if action
    control_add(c)
    c
  end

  def text_field_create(opts = {}, &action)
    params = {
      :x => 0,
      :y => 0
    }.deep_merge(opts)
    c = TextField.new
    c.relocate(params[:x], params[:y])
    c.set_on_action(action) if action
    control_add(c)
    c
  end
  
end