module Merb
  module Helpers
    # Provides a number of methods for creating form tags that doesn't rely on an object assigned to the template like
    # FormHelper does. Instead, you provide the names and values manually.
    #
    # NOTE: The HTML options <tt>disabled</tt>, <tt>readonly</tt>, and <tt>multiple</tt> can all be treated as booleans. So specifying 
    # <tt>:disabled => true</tt> will give <tt>disabled="disabled"</tt>.
    module FormTagHelper
      # Starts a form tag that points the action to an url configured with <tt>url_for_options</tt> just like
      # Merb::Helpers::TagHelper#url_for. The method for the form defaults to POST.
      #
      # ==== Options
      # * <tt>:multipart</tt> - If set to true, the enctype is set to "multipart/form-data".
      # * <tt>:method</tt>    - The method to use when submitting the form, usually either "get" or "post".
      #                         If "put", "delete", or another verb is used, a hidden input with name _method 
      #                         is added to simulate the verb over post.
      # * A list of parameters to feed to the URL the form will be posted to.
      #
      # ==== Examples
      #   form_tag('/posts')                      
      #   # => <form action="/posts" method="post">
      #
      #   form_tag('/posts/1', :method => :put)   
      #   # => <form action="/posts/1" method="put">
      #
      #   form_tag('/upload', :multipart => true) 
      #   # => <form action="/upload" method="post" enctype="multipart/form-data">
      # 
      #   <% form_tag '/posts' do -%>
      #     <div><%= submit_tag 'Save' %></div>
      #   <% end -%>
      #   # => <form action="/posts" method="post"><div><input type="submit" name="submit" value="Save" /></div></form>
      def form_tag(url_for_options = {}, options = {}, *parameters_for_url, &block)
        html_options = html_options_for_form(url_for_options, options, *parameters_for_url)
        if block_given?
          form_tag_in_block(html_options, &block)
        else
          form_tag_html(html_options)
        end
      end
      
      private
        def html_options_for_form(url_for_options, options, *parameters_for_url)
          returning options.stringify_keys do |html_options|
            html_options["enctype"] = "multipart/form-data" if html_options.delete("multipart")
            html_options["action"]  = url_for(url_for_options, *parameters_for_url)
          end
        end
        
        def extra_tags_for_form(html_options)
          case method = html_options.delete("method").to_s
            when /^get$/i # must be case-insentive, but can't use downcase as might be nil
              html_options["method"] = "get"
              ''
            when /^post$/i, "", nil
              html_options["method"] = "post"
              ''
            else
              html_options["method"] = "post"
              content_tag(:div, tag(:input, :type => "hidden", :name => "_method", :value => method) + token_tag, :style => 'margin:0;padding:0')
          end
        end
        
        def form_tag_html(html_options)
          extra_tags = extra_tags_for_form(html_options)
          open_tag("form", html_options) + extra_tags
        end
        
        def form_tag_in_block(html_options, &block)
          content = capture(&block)
          concat(form_tag_html(html_options), block.binding)
          concat(content, block.binding)
          concat("</form>", block.binding)
        end

        def token_tag
          unless protect_against_forgery?
            ''
          else
            tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
          end
        end
    end
  end
end

class Merb::ViewContext #:nodoc:
  include Merb::Helpers::FormTagHelper
end