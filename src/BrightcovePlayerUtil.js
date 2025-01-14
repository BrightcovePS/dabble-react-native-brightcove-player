import { NativeEventEmitter, NativeModules, Platform } from 'react-native';

const offlineNotificationEmitter = new NativeEventEmitter(
  NativeModules.BrightcovePlayerUtil
);

const requestDownloadVideoWithReferenceId = function(
  accountId,
  policyKey,
  referenceId,
  bitRate
) {
  return NativeModules.BrightcovePlayerUtil.requestDownloadVideoWithReferenceId(
    referenceId,
    accountId,
    policyKey,
    bitRate || 0
  );
};

const requestDownloadVideoWithVideoId = function(
  accountId,
  policyKey,
  videoId,
  bitRate
) {
  return NativeModules.BrightcovePlayerUtil.requestDownloadVideoWithVideoId(
    videoId,
    accountId,
    policyKey,
    bitRate || 0
  );
};

const requestPauseDownloadVideoWithTokenId = function(
  accountId,
  policyKey,
  videoId,
  videoToken
  ) {
    if (Platform.OS === 'ios') {
      return NativeModules.BrightcovePlayerUtil.requestPauseDownloadVideoWithTokenId(
        videoToken
      );
    } else {
      return NativeModules.BrightcovePlayerUtil.requestPauseDownloadVideoWithTokenId(
        accountId,
        policyKey,
        videoId
      );
    }
};

const requestResumeDownloadVideoWithTokenId = function(
  accountId,
  policyKey,
  videoId,
  videoToken
  ) {
    if (Platform.OS === 'ios') {
      return NativeModules.BrightcovePlayerUtil.requestResumeDownloadVideoWithTokenId(
        videoToken
      );
    } else {
      return NativeModules.BrightcovePlayerUtil.requestResumeDownloadVideoWithTokenId(
        accountId,
        policyKey,
        videoId
      )
    }
};

const getOfflineVideoStatuses = function(accountId, policyKey) {
  return NativeModules.BrightcovePlayerUtil.getOfflineVideoStatuses(
    accountId,
    policyKey
  );
};

const deleteOfflineVideo = function(accountId, policyKey, videoToken) {
  return NativeModules.BrightcovePlayerUtil.deleteOfflineVideo(
    accountId,
    policyKey,
    videoToken
  );
};

const getPlaylistWithReferenceId = function(accountId, policyKey, referenceId) {
  return NativeModules.BrightcovePlayerUtil.getPlaylistWithReferenceId(
    referenceId,
    accountId,
    policyKey
  );
};

const getPlaylistWithPlaylistId = function(accountId, policyKey, playlistId) {
  return NativeModules.BrightcovePlayerUtil.getPlaylistWithPlaylistId(
    playlistId,
    accountId,
    policyKey
  );
};

const addOfflineNotificationListener = function(callback) {
  return offlineNotificationEmitter.addListener(
    'OfflineNotification',
    callback
  );
};

module.exports = {
  requestPauseDownloadVideoWithTokenId,
  requestResumeDownloadVideoWithTokenId,
  requestDownloadVideoWithReferenceId,
  requestDownloadVideoWithVideoId,
  getOfflineVideoStatuses,
  deleteOfflineVideo,
  getPlaylistWithReferenceId,
  getPlaylistWithPlaylistId,
  addOfflineNotificationListener
};
