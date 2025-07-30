require_relative 'puma_writer'

module Chitragupta::Integrations::Puma
  def self.install!
    return unless defined?(::Puma::Events)
    out, err = PumaWriter.new(:info), PumaWriter.new(:error)
    ::Puma::Events.singleton_class.prepend(
      Module.new do
        define_method(:default) { |*| super(out, err) }
      end
    )
  end
end