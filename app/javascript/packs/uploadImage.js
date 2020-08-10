$('#micropost_image').bind('change', function() {
  var size_in_megabytes = this.files[0].size/1024/1024;
  if (size_in_megabytes > Settings.micropost.image.sizse) {
    alert(I18n.t('microposts.image.image_size'));
  }
});
