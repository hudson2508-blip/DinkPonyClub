# frozen_string_literal: true

class GalleryPhotosController < ApplicationController
  include SeasonScoped

  before_action :require_sign_in
  before_action :set_season
  before_action :require_upload_access, only: %i[create destroy]

  def index
    @photos = GalleryPhoto.where(season: @season).includes(:player, image_attachment: :blob).order(created_at: :desc)
    @photo = GalleryPhoto.new
  end

  def create
    @photo = GalleryPhoto.new(photo_params.merge(season: @season, player: current_player))
    if @photo.save
      redirect_to season_gallery_photos_path(@season), notice: 'Photo uploaded.'
    else
      @photos = GalleryPhoto.where(season: @season).includes(:player, image_attachment: :blob).order(created_at: :desc)
      render :index, status: :unprocessable_content
    end
  end

  def destroy
    photo = GalleryPhoto.where(season: @season).find(params[:id])
    unless admin? || photo.player_id == current_player.id
      return redirect_to season_gallery_photos_path(@season), alert: 'You can only remove photos you uploaded.'
    end

    photo.destroy!
    redirect_to season_gallery_photos_path(@season), notice: 'Photo removed.'
  end

  private

  def set_season
    @season = current_season
    redirect_to seasons_path, alert: 'Choose a season first.' unless @season
  end

  def require_upload_access
    return if @season && captain_or_admin?(@season)

    redirect_to (@season ? season_gallery_photos_path(@season) : seasons_path), alert: 'Only captains and admins can manage photos.'
  end

  def photo_params
    params.expect(gallery_photo: [:caption, :image])
  end
end
