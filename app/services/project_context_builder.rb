class ProjectContextBuilder
  def self.call(project)
    <<~PROMPT
      STARTUP CONTEXT

      Startup Name:
      #{project.title}

      Problem:
      #{project.problem_context}

      Current Solution:
      #{project.current_solution}

      Business Model:
      #{project.business_model}

      Use this context for all answers unless the user explicitly changes it.
    PROMPT
  end
end
