class Attendance < ActiveRecord::Base
  include GithubHandle #concern

  belongs_to :user
  belongs_to :conference
end
