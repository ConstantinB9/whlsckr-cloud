# whlsckr-cloud

<style>
.custom-image {
  width: 50px;
  height: auto;
}
</style>

<img src="https://user-images.githubusercontent.com/25181517/183423507-c056a6f9-1ba8-4312-a350-19bcbc5a8697.png" alt="image" style="width: 50px; height: auto;">
<img src="https://user-images.githubusercontent.com/25181517/183896132-54262f2e-6d98-41e3-8888-e40ab5a17326.png" alt="image" style="width: 50px; height: auto;">
<img src="https://user-images.githubusercontent.com/25181517/183345121-36788a6e-5462-424a-be67-af1ebeda79a2.png" alt="image" style="width: 50px; height: auto;">



A tool to take ownership on what information is public about your sports activities uploaded to social platforms

### Problem
Not all Social Platforms allow for uploading sport activities (namely Strava) allow for easy control of what data should be private by default.
By uploading only parts of an activity and omitting private data the analytics may not be as good and the data will not be available for the user.

### Solution for Strava using Wahoo Devices
*whlsckr-cloud* will upload the data for you and after uploading will edit the privacy settings to match your desired preset.
For this to work the user has to upload to a dropbox folder. *whlsckr-cloud* will grab the activity file from there and upload it to Strava.
Wahoo Devices support this behavior out-of-the-box. However, the automatic strava upload has to be disabled.

## Architecture
![Architecture]{docs/achitecture.png}

