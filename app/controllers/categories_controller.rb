require 'nokogiri'
require 'open-uri'
require 'json'
class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.all
    @posts = Post.all.paginate(page: params[:page],per_page: 4)
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @categories = Category.all
    @posts = @category.posts.paginate(page: params[:page],per_page: 4)
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: 'Category was successfully created.' }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: 'Category was successfully updated.' }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_url, notice: 'Category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def crawl
    @categories = Category.all

    @categories.each do |category|
      articles_links = Nokogiri::HTML(open('http://9gag.com/' + category.name))
      articles_links.xpath('//article/@data-entry-url').each do |link|
        article = Nokogiri::HTML(open(link))
        article_id = (link.text).rpartition('/').last

        title = article.xpath('//header/h2').text

        point_of_article = "a#love-count-" + article_id + " span span.badge-item-love-count"
        point = article.css(point_of_article).text

        idx = 0
        img_url = article.xpath('//img').first['src']

        post = Post.create(category_id: category_id, title: title, image_url: image_url, point: point) 

        comment_url = "http://d8d94e0wul1nb.cloudfront.net/comment?callback=comment_list&appId=a_dd8f2b7d304a10edaf6f29517ea0ca4100a43d1b&url=http%3A%2F%2F9gag.com%2Fgag%2F" + article_id + "&order=score&count=10&level=2&ref=&refCommentId=&commentId="  
        result = Net::HTTP.get(URI.parse(comment_url))
        comment_json_data = result[13..result.length-3]
        comment_data = JSON.parse(comment_json_data)
        comment_list = comment_data["payload"]["comments"]
        comment_list.each do |comment|
          name = comment["commentId"]
          body = comment["text"]
          post_id = post.id

          Comment.create(:post_id=>post_id, :name=>name, :body=>body)
        end    
 
      end
    end
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name)
    end
end
