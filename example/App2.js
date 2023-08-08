import * as React from 'react';
import HomeScreen from './HomeScreen'
import AboutScreen from './AboutScreen'
import App3 from './App3'

import { NavigationContainer } from "@react-navigation/native"
import { createNativeStackNavigator } from "@react-navigation/native-stack"

const Stack = createNativeStackNavigator()

export default function App() { 
  return ( 
    <NavigationContainer> 
      <Stack.Navigator> 
        <Stack.Screen name="HomeScreen" component = {HomeScreen} /> 
        <Stack.Screen name="AboutScreen" component = {AboutScreen} /> 
        <Stack.Screen name="App3" component = {App3} /> 

      </Stack.Navigator> 
    </NavigationContainer> 
  );
}