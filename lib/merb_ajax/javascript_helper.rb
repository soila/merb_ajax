module Merb
  module Helpers
    # Provides functionality for working with JavaScript in your views.
    # 
    # == Ajax, controls and visual effects
    # 
    # * For information on using Ajax, see 
    #   Merb::Helpers::PrototypeHelper.
    # * For information on using controls and visual effects, see
    #   Merb::Helpers::ScriptaculousHelper.
    #
    # == Including the JavaScript libraries into your pages
    #
    # merb_ajax provides helpers for the Prototype JavaScript framework and the
    # Scriptaculous JavaScript controls and visual effects library. If you wish
    # to use these libraries and their helpers (Merb::Helpers::PrototypeHelper
    # and Merb::Helpers::ScriptaculousHelper), you must include the respective
    # JavaScript files.
    #
    # Merb provides some helper methods for you:
    # Merb::Assets::AssetHelpers or Module: Merb :: ViewContextMixin
    module JavaScriptHelper
      # Returns a link that will trigger a JavaScript +function+ using the 
      # onclick handler and return false after the fact.
      #
      # The +function+ argument can be omitted in favor of an +update_page+
      # block, which evaluates to a string when the template is rendered
      # (instead of making an Ajax request first).      
      #
      # Examples:
      #   link_to_function "Greeting", "alert('Hello world!')"
      #     Produces:
      #       <a onclick="alert('Hello world!'); return false;" href="#">Greeting</a>
      #
      #   link_to_function(image_tag("delete"), "if (confirm('Really?')) do_delete()")
      #     Produces:
      #       <a onclick="if (confirm('Really?')) do_delete(); return false;" href="#">
      #         <img src="/images/delete.png?" alt="Delete"/>
      #       </a>
      #
      #   link_to_function("Show me more", nil, :id => "more_link") do |page|
      #     page[:details].visual_effect  :toggle_blind
      #     page[:more_link].replace_html "Show me less"
      #   end
      #     Produces:
      #       <a href="#" id="more_link" onclick="try {
      #         $(&quot;details&quot;).visualEffect(&quot;toggle_blind&quot;);
      #         $(&quot;more_link&quot;).update(&quot;Show me less&quot;);
      #       } 
      #       catch (e) { 
      #         alert('RJS error:\n\n' + e.toString()); 
      #         alert('$(\&quot;details\&quot;).visualEffect(\&quot;toggle_blind\&quot;);
      #         \n$(\&quot;more_link\&quot;).update(\&quot;Show me less\&quot;);');
      #         throw e 
      #       };
      #       return false;">Show me more</a>
      #
      def link_to_function(name, *args, &block)
        html_options = args.extract_options!
        function = args[0] || ''

        html_options.symbolize_keys!
        function = update_page(&block) if block_given?
        content_tag(
          "a", name, 
          html_options.merge({ 
            :href => html_options[:href] || "#", 
            :onclick => (html_options[:onclick] ? "#{html_options[:onclick]}; " : "") + "#{function}; return false;" 
          })
        )
      end
      
      # Returns a button that'll trigger a JavaScript +function+ using the 
      # onclick handler.
      #
      # The +function+ argument can be omitted in favor of an +update_page+
      # block, which evaluates to a string when the template is rendered
      # (instead of making an Ajax request first).      
      #
      # Examples:
      #   button_to_function "Greeting", "alert('Hello world!')"
      #   button_to_function "Delete", "if (confirm('Really?')) do_delete()"
      #   button_to_function "Details" do |page|
      #     page[:details].visual_effect :toggle_slide
      #   end
      #   button_to_function "Details", :class => "details_button" do |page|
      #     page[:details].visual_effect :toggle_slide
      #   end
      def button_to_function(name, *args, &block)
        html_options = args.extract_options!
        function = args[0] || ''

        html_options.symbolize_keys!
        function = update_page(&block) if block_given?
        tag("button", name, html_options.merge({
          :onclick => (html_options[:onclick] ? "#{html_options[:onclick]}; " : "") + "#{function};" 
        }))
      end
      
      # Escape carrier returns and single and double quotes for JavaScript segments.
      def escape_javascript(javascript)
        (javascript || '').gsub('\\','\0\0').gsub('</','<\/').gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }
      end
      
      # Returns a JavaScript tag with the +content+ inside. Example:
      #   javascript_tag "alert('All is good')"
      #
      # Returns:
      #   <script type="text/javascript">
      #   //<![CDATA[
      #   alert('All is good')
      #   //]]>
      #   </script>
      #
      # +html_options+ may be a hash of attributes for the <script> tag. Example:
      #   javascript_tag "alert('All is good')", :defer => 'defer' 
      #   # => <script defer="defer" type="text/javascript">alert('All is good')</script>
      #
      # Instead of passing the content as an argument, you can also use a block
      # in which case, you pass your +html_options+ as the first parameter.
      #   <% javascript_tag :defer => 'defer' do -%>
      #     alert('All is good')
      #   <% end -%>
      def javascript_tag(content_or_options_with_block = nil, html_options = {}, &block)
        if block_given?
          html_options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
          content = capture(&block)
        else
          content = content_or_options_with_block
        end

        javascript_tag = content_tag("script", javascript_cdata_section(content), html_options.merge(:type => Merb.available_mime_types[:js].first))
        
        if block_given? && block_is_within_action_view?(block)
          concat(javascript_tag, block.binding)
        else
          javascript_tag
        end
      end

      def javascript_cdata_section(content) #:nodoc:
        "\n//#{cdata_section("\n#{content}\n//")}\n"
      end
      
    protected
      def options_for_javascript(options)
        '{' + options.map {|k, v| "#{k}:#{v}"}.sort.join(', ') + '}'
      end
      
      def array_or_string_for_javascript(option)
        js_option = if option.kind_of?(Array)
          "['#{option.join('\',\'')}']"
        elsif !option.nil?
          "'#{option}'"
        end
        js_option
      end

    private
      def block_is_within_action_view?(block)
        eval("defined? _erbout", block.binding)
      end
    end

    JavascriptHelper = JavaScriptHelper unless const_defined? :JavascriptHelper
  end
end

class Merb::ViewContext #:nodoc:
  include Merb::Helpers::JavascriptHelper
end