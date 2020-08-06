module UsersHelper
  def gravatar_for user, options = {size: Settings.avatar_size}
    size = options[:size]
    gravatar_id = Digest::MD5.hexdigest user.email.downcase
    gravatar_url = Settings.gravatar_avatar_url + gravatar_id + "?s=#{size}"
    image_tag gravatar_url, alt: user.name, class: "gravatar"
  end
end
