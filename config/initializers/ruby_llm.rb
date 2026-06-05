RubyLLM.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"].presence || ENV["GITHUB_TOKEN"]

  if ENV["GITHUB_TOKEN"].present? && ENV["OPENAI_API_KEY"].blank?
    config.openai_api_base = "https://models.inference.ai.azure.com"
  end
end
