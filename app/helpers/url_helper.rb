module UrlHelper #included in class Source
  def normalize_url(url)
    url = url.strip if url
    (url.present? && url !~ /^(http|file)/) ? "http://#{url}" : url
  end
end
