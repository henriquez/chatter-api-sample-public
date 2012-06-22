module ApplicationHelper
  
  # used to load js files on a per controller basis
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end
  

  

end
