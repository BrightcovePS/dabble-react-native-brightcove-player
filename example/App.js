import React, {Component} from 'react';
import {
  FlatList,
  StatusBar,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  Platform,
  Alert
} from 'react-native';
import {
  BrightcovePlayer,
  BrightcovePlayerPoster,
  BrightcovePlayerUtil,
} from 'react-native-brightcove-player';

const ACCOUNT_ID = '2779557264001';
const POLICY_KEY =
  'BCpkADawqM0mZx1lVrdIUv9B0iOcBlFLj0vfKKE8rOCEZBYbUDvTR6m-LSUbiho5BP1nLhhXaqmMROcJvU_u2tc6lO0i6GDmBeiVj09BAdxK5fSyfgFwBz3RCpRA_vsB0ZEbwl59K7ha6Sbd';
const PLAYLIST_REF_ID = 'most_played';

export default class App extends Component {
  state = {
    videos: [],
    offlineVideos: [],
    playback: {
      play: false,
      videoToken: null,
      videoId: null,
    },
    closed:false
  };

  componentDidMount() {
    BrightcovePlayerUtil.getPlaylistWithReferenceId(
      ACCOUNT_ID,
      POLICY_KEY,
      PLAYLIST_REF_ID,
    )
      .then(videos => {
        this.setState({
          videos,
          closed:false
        });

      })
      .catch(console.warn);
    BrightcovePlayerUtil.getOfflineVideoStatuses(ACCOUNT_ID, POLICY_KEY)
      .then(offlineVideos => {
        this.setState({
          offlineVideos,
        });
      })
      .catch(console.warn);
    this.disposer = BrightcovePlayerUtil.addOfflineNotificationListener(
      offlineVideos => {
        this.setState({
          offlineVideos,
        });
      },
    );
  }

  requestDownload(videoId) {
    BrightcovePlayerUtil.requestDownloadVideoWithVideoId(
      ACCOUNT_ID,
      POLICY_KEY,
      videoId,
    ).catch((error) => {console.error(error)});
  }

  pauseDownload(videoToken, videoId) {
      BrightcovePlayerUtil.requestPauseDownloadVideoWithTokenId(
        ACCOUNT_ID,
        POLICY_KEY,
        videoId,
        videoToken
      ).catch((error) => {console.error(error)});
  }

  resumeDownload(videoToken, videoId) {
      BrightcovePlayerUtil.requestResumeDownloadVideoWithTokenId(
        ACCOUNT_ID,
        POLICY_KEY,
        videoId,
        videoToken
      ).catch((error) => {console.error(error)});
  }

  play(item) {
    const downloadStatus = this.state.offlineVideos.find(
      video => video.videoId === item.videoId,
    );


    this.setState({
      playback:
        downloadStatus && downloadStatus.downloadProgress === 1
          ? {
              ...this.state.playback,
              videoToken: downloadStatus.videoToken,
              videoId: item.videoId
            }
          : {
              ...this.state.playback,
              videoId: item.videoId,
              videoToken: null
            },
            closed:false
    });
  }

  delete(videoToken) {
    BrightcovePlayerUtil.deleteOfflineVideo(
      ACCOUNT_ID,
      POLICY_KEY,
      videoToken,
    ).catch(console.warn);
  }

  componentWillUnmount() {
    this.disposer && this.disposer();
  }

  onPressPlayPause = () => {
    this.setState((state, props) => {
      return {
        state,
        playback: {
          ...state.playback,
          play: !state.playback.play
        },
      };
    });
  };

  onPlayNext = event => {
    this.setState((state, props) => {
      return {
        state,
        playback: {
          ...state.playback,
          videoId: event.videoId,
          play: true
        },
      };
    });
  };

  onCloseTapped = Event => {
    console.log("close called")
    this.setState({
          closed : true,
        });

  }
  onError = event => {
    // Alert.alert(
    //   'onError',
    //   '', // <- this part is optional, you can pass an empty string
    //   [
    //     {text: 'OK', onPress: () => console.log('OK Pressed')},
    //   ],
    //   {cancelable: false},
    // );
    console.log("Error", event)
  };
  onPause = event => {
    console.log("Pause called")
  };
  onPlay = event => {
    console.log("Play called")
     this.setState({
          closed : false,
        });
  };

  onVideoSize = event => {
    console.log("Video Size", event.width, event.height)
    // Alert.alert(
    //   'Video Size',
    //   'w:' + event.width + '  h:' + event.height, // <- this part is optional, you can pass an empty string
    //   [
    //     {text: 'OK', onPress: () => console.log('OK Pressed')},
    //   ],
    //   {cancelable: false},
    // );
  };

  render() {
    return (
      <View style={styles.container}>
        <StatusBar barStyle="light-content" />
        <BrightcovePlayer
          autoPlay = {true}
          style={{ width: '100%', height: this.state.closed ? 0:300 }}
          accountId={ACCOUNT_ID}
          policyKey={POLICY_KEY}
          seekDuration={15000}
          playlistReferenceId={PLAYLIST_REF_ID}
          {...this.state.playback}
          onPlayNextVideo={this.onPlayNext}
          onError={this.onError}
          onVideoSize={this.onVideoSize}
          onPause={this.onPause}
          onPlay={this.onPlay}
          onCloseTapped = {this.onCloseTapped}
        />
        <TouchableOpacity
          style={styles.playPauseButton}
          onPress={this.onPressPlayPause}>
          <Text>
            {' '}
            Playing status: {this.state.playback.play
              ? 'Playing'
              : 'Paused'}{' '}
          </Text>
        </TouchableOpacity>
        <FlatList
          style={styles.list}
          extraData={this.state.offlineVideos}
          data={this.state.videos}
          keyExtractor={item => item.videoId}
          renderItem={({item}) => {
            const downloadStatus = this.state.offlineVideos.find(
              video => video.videoId === item.videoId,
            );
            return (
              <View style={styles.listItem}>
                <TouchableOpacity
                  style={styles.mainButton}
                  onPress={() => this.play(item)}>
                  <BrightcovePlayerPoster
                    style={styles.poster}
                    accountId={ACCOUNT_ID}
                    policyKey={POLICY_KEY}
                    videoId={item.videoId}
                  />
                  <View style={styles.body}>
                    <Text style={styles.name}>{item.name}</Text>
                    <Text>{item.description}</Text>
                    {downloadStatus ? (
                      <Text style={styles.offlineBanner}>
                        {downloadStatus.downloadProgress === 1
                          ? 'OFFLINE PLAYBACK' :
                           downloadStatus.videoStatus === 2 ? `PAUSED: ${Math.floor(
                              downloadStatus.downloadProgress * 100,
                            )}% ` 
                          : downloadStatus.videoStatus === 5 ? 'Error' :  `DOWNLOADING: ${Math.floor(
                              downloadStatus.downloadProgress * 100,
                            )}%`}
                      </Text>
                    ) : null}
                    <Text style={styles.duration}>
                      {`0${Math.floor(item.duration / 60000) % 60}`.substr(-2)}:
                      {`0${Math.floor(item.duration / 1000) % 60}`.substr(-2)}
                    </Text>
                  </View>
                </TouchableOpacity>
                <TouchableOpacity
                  style={styles.downloadButton}
                  onPress={() => {
                    if (!downloadStatus) {
                      this.requestDownload(item.videoId);
                    } 
                    else if (downloadStatus.downloadProgress === 1) {
                      this.delete(downloadStatus.videoToken);
                    } 
                    else if(downloadStatus.videoStatus === 2) {
                      this.resumeDownload(downloadStatus.videoToken, item.videoId);
                    } 
                    else if(downloadStatus.videoStatus === 5) {
                      this.delete(downloadStatus.videoToken);
                    }
                    else {
                      this.pauseDownload(downloadStatus.videoToken, item.videoId);
                    } 
                  }}>
                  <Text>
                    {!downloadStatus
                      ? item.canBeDownloaded ? '💾':''
                      : downloadStatus.downloadProgress === 1
                      ? '🗑'
                      : '⏳'}
                  </Text>
                </TouchableOpacity>
                 <TouchableOpacity
                  style={styles.downloadButton}
                  onPress={() => {
                    if (downloadStatus) {
                             this.delete(downloadStatus.videoToken);
                    } 
                  }}>
                  <Text>
                    {downloadStatus &&  downloadStatus.downloadProgress != 1? '❌':''}
                  </Text>
                </TouchableOpacity>

              </View>
            );
          }}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
  },
  list: {
    flex: 1,
  },
  listItem: {
    flexDirection: 'row',
    borderBottomWidth: 1,
    borderBottomColor: 'lightgray',
  },
  mainButton: {
    flex: 1,
    flexDirection: 'row',
  },
  body: {
    flex: 1,
    padding: 10,
    flexDirection: 'column',
  },
  name: {
    fontSize: 14,
    fontWeight: 'bold',
  },
  offlineBanner: {
    fontSize: 10,
    fontWeight: 'bold',
    color: 'white',
    alignSelf: 'flex-start',
    padding: 3,
    backgroundColor: 'deepskyblue',
  },
  duration: {
    marginTop: 'auto',
    opacity: 0.5,
  },
  poster: {
    width: 100,
    height: 100,
    backgroundColor: 'black',
  },
  downloadButton: {
    padding: 16,
    marginLeft: 'auto',
    alignSelf: 'center',
  },
  playPauseButton: {
    alignItems: 'center',
    backgroundColor: '#DDDDDD',
    padding: 10,
  },
});