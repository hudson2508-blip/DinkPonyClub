require 'test_helper'

class GalleryPhotosControllerTest < ActionDispatch::IntegrationTest
  test 'signed-in members can view the gallery' do
    sign_in_as(players(:grace))
    get season_gallery_photos_path(seasons(:fall))
    assert_response :success
    assert_select 'h1', text: 'Photos'
    assert_select 'input[type=file]', count: 0
  end

  test 'captains see the upload form' do
    sign_in_as(players(:ada))
    get season_gallery_photos_path(seasons(:fall))
    assert_response :success
    assert_select 'input[type=file]', count: 1
  end

  test 'non-captains cannot upload' do
    sign_in_as(players(:grace))
    post season_gallery_photos_path(seasons(:fall)), params: { gallery_photo: { caption: 'Nope' } }
    assert_redirected_to season_gallery_photos_path(seasons(:fall))
    assert_equal 0, GalleryPhoto.count
  end

  test 'captain can upload and remove their own photo' do
    sign_in_as(players(:ada))
    Tempfile.create(['gallery', '.png']) do |file|
      file.binmode
      file.write(Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aO8AAAAASUVORK5CYII='))
      file.flush
      upload = Rack::Test::UploadedFile.new(file.path, 'image/png')
      assert_difference 'GalleryPhoto.count', 1 do
        post season_gallery_photos_path(seasons(:fall)), params: { gallery_photo: { caption: 'Match night', image: upload } }
      end
    end
    photo = GalleryPhoto.last
    assert_redirected_to season_gallery_photos_path(seasons(:fall))
    assert_equal players(:ada), photo.player
    assert photo.image.attached?
    assert_difference 'GalleryPhoto.count', -1 do
      delete season_gallery_photo_path(seasons(:fall), photo)
    end
  end

  test 'captains cannot delete another captains photos' do
    photo = GalleryPhoto.new(season: seasons(:fall), player: players(:zoe))
    photo.image.attach(io: StringIO.new('fake image'), filename: 'photo.png', content_type: 'image/png')
    photo.save!
    sign_in_as(players(:ada))
    assert_no_difference 'GalleryPhoto.count' do
      delete season_gallery_photo_path(seasons(:fall), photo)
    end
    assert_redirected_to season_gallery_photos_path(seasons(:fall))
  end
end
