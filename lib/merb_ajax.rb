module Merb
  
  module Ajax
    CORE_EXT_DIR = File.dirname(__FILE__) / 'core_ext'
    CORE_EXT_FILES = Dir["#{CORE_EXT_DIR}/*.rb"].collect {|h| h.match(/\/(\w+)\.rb/)[1]}
    HELPERS_DIR = File.dirname(__FILE__) / 'merb_ajax'
    HELPERS_FILES = Dir["#{HELPERS_DIR}/*_helper.rb"].collect {|h| h.match(/\/(\w+)\.rb/)[1]}
    MIXINS_DIR = File.dirname(__FILE__) / 'mixins'
    MIXINS_FILES = Dir["#{MIXINS_DIR}/*.rb"].collect {|h| h.match(/\/(\w+)\.rb/)[1]}
      
    def self.load_helpers(helpers = HELPERS_FILES)
      helpers.each {|h| Kernel.load(File.join(HELPERS_DIR, "#{h}.rb") )}
    end
    
    def self.load_core_ext(core = CORE_EXT_FILES)
      core.each {|s| Kernel.load(File.join(CORE_EXT_DIR, "#{s}.rb") )}
    end
    
    def self.load_mixins(mixins = MIXINS_FILES)
      mixins.each {|s| Kernel.load(File.join(MIXINS_DIR, "#{s}.rb") )}
    end
    
    def self.load
      load_core_ext
      load_mixins
      load_helpers
      Merb::Plugins.add_rakefiles "merb_ajax/merbtasks"
    end    
  end
  
end

Merb::Ajax.load if defined?(Merb::Plugins)