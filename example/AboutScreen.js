import * as React from 'react';
import { Text, View, StyleSheet, Button } from 'react-native';

export default function AboutScreen({route}) { 
  let dataObj = route.params

  return ( 
    <View style={styles.container}> 
      <Text style={styles.paragraph}> 
        This is the About Screen of  
      </Text> 
    </View> 
  );
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