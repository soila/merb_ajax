module Merb
  module RenderMixin
      # Uses the JavaScriptGenerator to render a JavaScript block, updating the current view.
      # (similar to Rails' render :update)
      #
      #   render_js_block do |page|
      #     page.replace_html  'user_list', :partial => 'user', :collection => @users
      #     page.visual_effect :highlight, 'user_list'
      #   end
      def render_js_block(&blk)
        generator = Merb::Helpers::PrototypeHelper::JavaScriptGenerator.new(@template, &blk)
        return render(:js => generator.to_s, :layout => :none)
      end
  end
end