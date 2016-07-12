module Uploadcare::Rails::ActionView
  module IncludeTags
    def include_uploadcare_widget_from_cdn(options = {})
      @options = options
      @minified = settings[:min] ? 'min' : nil

      javascript_include_tag(url.to_s)
    end

    alias_method :inlude_uploadcare_widget, :include_uploadcare_widget_from_cdn
    alias_method :uplodacare_widget, :include_uploadcare_widget_from_cdn

    def uploadcare_settings(options = {})
      javascript_tag(js_settings(options))
    end

    def js_settings(options = {})
      ''.tap do |js_settings|
        widget_settings(options).each do |k, v|
          js_settings <<
            "UPLOADCARE_" +
              if v.is_a?(TrueClass) || v.is_a?(FalseClass)
                "#{ k.to_s.underscore.upcase } = #{ v };\n"
              else
                "#{ k.to_s.underscore.upcase } = \"#{ v }\";\n"
              end
        end
      end
    end

    def widget_settings(options = {})
      UPLOADCARE_SETTINGS.widget_settings.merge!(options)
    end

    def settings
      @_settings ||= {
        min: true,
        version: UPLOADCARE_SETTINGS.widget_version
      }.merge!(@options)
    end

    def path
      @_path ||= [
        'widget',
        settings[:version],
        'uploadcare',
        ['uploadcare', @minified, 'js'].compact.join('.')
      ].join('/')
    end

    def url
      URI::HTTPS.build(host: 'ucarecdn.com', path: '/' + path, scheme: :https)
    end
  end
end

ActionView::Base.send :include, Uploadcare::Rails::ActionView::IncludeTags
