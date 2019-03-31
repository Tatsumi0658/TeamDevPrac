class ArticlesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_article, only: %i[show edit update destroy]

  def index
    @agendas = Agenda.all
    @articles = Article.all
  end

  def show
    @comments = @article.comments
    @comment = @article.comments.build
    @working_team = @article.team
    change_keep_team(current_user, @working_team)
  end

  def new
    if @agenda = Agenda.find_by(id: params[:agenda_id])
      @team = @agenda.team
      @article = @agenda.articles.build
    else
      redirect_to dashboard_url, notice: "該当のアジェンダがありません"
    end
  end

  def edit
    change_keep_team(current_user, @article.team)
  end

  def create
    if @agenda = Agenda.find_by(id: params[:agenda_id])
      @article = @agenda.articles.build(article_params)
      @article.user = current_user
      @article.team_id = @agenda.team_id
      if Assign.where(user_id: current_user.id).where(team_id: @agenda.team_id).present? && @article.save
        redirect_to article_url(@article), notice: '記事作成に成功しました！'
      else
        render :new
      end
    else
      render :new
    end
  end

  def update
    if Assign.where(user_id: current_user.id).where(team_id: @article.agenda.team_id).present?
      if @article.update(article_params)
        redirect_to @article, notice: '記事更新に成功しました！'
      else
        render :edit
      end
    else
      redirect_to dashboard_url, notice: "権限がありません"
    end
  end

  def destroy
    if Assign.where(user_id: current_user.id).where(team_id: @article.agenda.team_id).present?
      @article.destroy
      redirect_to dashboard_url
    else
      redirect_to dashboard_url, notice:"権限がありません"
    end
  end

  private

  def set_article
    if Article.find_by(id: params[:id])
      @article = Article.find(params[:id])
    else
      redirect_to dashboard_url, notice:"該当の記事はありません"
    end
  end

  def article_params
    params.fetch(:article, {}).permit %i[title content image image_cache]
  end
end
