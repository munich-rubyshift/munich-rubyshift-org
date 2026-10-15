class Avo::Actions::MirrorGithubAvatar < Avo::BaseAction
  self.name = "Mirror GitHub avatar"
  self.no_confirmation = true
  self.visible = -> { view.show? }

  def handle(query:, **)
    query.each do |person|
      if person.github_username.blank?
        error "#{person} has no GitHub username."
      elsif person.mirror_github_avatar!
        succeed "Mirrored #{person}'s avatar from GitHub."
      else
        error person.errors.full_messages.to_sentence
      end
    rescue OpenURI::HTTPError, SocketError, SystemCallError, Timeout::Error => e
      error "Couldn't download #{person}'s avatar from GitHub: #{e.message}"
    end
  end
end
