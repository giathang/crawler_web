json.array!(@posts) do |post|
  json.extract! post, :id, :cat_id, :point, :title, :image_url
  json.url post_url(post, format: :json)
end
