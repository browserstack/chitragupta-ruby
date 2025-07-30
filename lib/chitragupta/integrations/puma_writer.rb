class Chitragupta::Integrations::PumaWriter
  def initialize(level)
    @logger = Chitragupta::Logger.new($stdout)
    @level  = level               # :info or :error
  end

  def <<(msg)                     # Puma calls this
    @logger.public_send(@level,
      log:  { kind: 'PUMA', dynamic_data: msg.to_s.strip },
      meta: { component: 'puma' }
    )
  rescue => e                     # never crash Puma
    STDERR.puts "CG-PumaWriter error: #{e}"
  end
end