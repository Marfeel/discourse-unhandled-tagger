# frozen_string_literal: true

# name: discourse-unhandled-tagger
# about: Add an "unhandled" tag to every topic where non-staff post
# version: 0.1
# authors: Sam Saffron

after_initialize do
  DiscourseEvent.on(:post_created) do |post, _, user|
    next if SiteSetting.unhandled_tag.blank?

    tag = Tag.find_or_create_by!(name: SiteSetting.unhandled_tag)

    ActiveRecord::Base.transaction do
      topic = post.topic
      isUnhandled = topic.tags.pluck(:id).include?(tag.id)
      isStaff = user.staff? || user.email&.end_with?("@marfeel.com")

      if !isUnhandled && !user.staff?
        topic.tags.reload
        topic.tags << tag
        topic.save
      elsif isUnhandled && user.staff?
        topic.tags.reload
        topic.tags.delete(tag.id)
        topic.save
      end
    end
  end
end
