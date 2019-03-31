class CommentsController < ApplicationController
  def create
    @article = Article.find_by(id: params[:article_id])
    @comment = @article.comments.build(comment_params)
    @comment.user_id = current_user.id
    respond_to do |format|
      if @comment.save
        format.js { render :index }
      else
        @comments = @article.comments
        @comment = @article.comments.build
        format.html { redirect_to article_path(@article), notice:"投稿できませんでした。" }
      end
    end
  end

  def edit
    @comment = Comment.find_by(id: params[:id])
  end

  def update
    if @comment = Comment.find_by(id: params[:id])
      @article = @comment.article
      if @comment.update(comment_params)
        redirect_to article_path(@article), notice:"更新しました"
      else
        render :edit
      end
    else
      render :edit
    end
  end

  def destroy
    @comment = Comment.find_by(id: params[:id])
    if @comment.destroy
      respond_to do |format|
        format.js { render :index }
      end
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:article_id, :content, :user_id)
  end
end
