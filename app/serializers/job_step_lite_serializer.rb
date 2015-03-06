class JobStepLiteSerializer < ActiveModel::Serializer
  attributes :source, :beginDelimiter, :endDelimiter

  def beginDelimiter
    '----BEGIN PANAMAX DATA----'
  end

  def endDelimiter
    '----END PANAMAX DATA----'
  end
end
