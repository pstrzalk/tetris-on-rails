class Question
  attr_reader :content, :correct_answer, :answers

  def initialize(content, correct_answer, answers)
    @content = content
    @correct_answer = correct_answer
    @answers = answers
  end
end
