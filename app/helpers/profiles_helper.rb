module ProfilesHelper #included in User class, class Team; 
  def github_handle=(handle)
    super(normalize_handle(handle))
  end

  def twitter_handle=(handle)
    handle = normalize_handle(handle)
    super(handle.present? && "@#{handle}" || nil)
  end

  def twitter_url
    "http://twitter.com/#{twitter_handle.to_s.sub('@', '')}"
  end

  def github_url
    "https://github.com/#{github_handle}"
  end

  def normalize_handle(handle)
    handle.to_s.sub(%r(^https?://[^/]+/), '').sub(/^@/, '').split('/').first.try(:strip)
  end
end
