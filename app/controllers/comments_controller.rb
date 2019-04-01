class CommentsController < ApplicationController
  def create
    @article = Article.find_by(id: params[:article_id])
    @comment = @article.comments.build(comment_params)
    @comment.user_id = current_user.id
    respond_to do |format|
      if @comment.save
        format.js { render :index }
      else
        format.js { render :form }
      end
    end
  end

  def edit
    unless @comment = Comment.find_by(id: params[:id])
      redirect_to dashboard_url, notice: "権限がありません"
    end
  end

  def update
    if @comment = Comment.find_by(id: params[:id])
      @article = @comment.article
      if @comment.user_id == current_user.id && @comment.update(comment_params)
        redirect_to article_path(@article), notice:"更新しました"
      else
        render :edit, notice: "更新できませんでした"
      end
    else
      render :edit, notice: "該当のコメントがありません"
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
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
