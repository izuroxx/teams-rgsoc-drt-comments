module GithubHandle
  extend ActiveSupport::Concern  #included in class Role (role.rb); class Attendance attendance.rb

  #methods below, if no in blocks "included do end" or "module ClassMethods" are instance methods:
  def github_handle
    user.try(:github_handle)
  end

  def github_handle=(github_handle)
    self.user = github_handle.present? && User.where(github_handle: github_handle).first || build_user
    user.github_handle = github_handle
  end
end
