module HasSeason
  extend ActiveSupport::Concern #included in Application class application.rb, ApplicationDraft class, aplication_draft.rb, class Conference conference.rb; class Project project.rb, Team class team.rb
#mThe code contained within the included block will be executed within the context of the class that is including the module.
  included do
    belongs_to :season
  end
end
