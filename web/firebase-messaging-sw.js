// web/firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: 'AIzaSyAWjGCiqwdgVYG86f6GADI2GJr8tXeuweM',
    appId: '1:1089764157877:web:d2ba3b6a4bf41408ca91fc',
    messagingSenderId: '1089764157877',
    projectId: 'momentumapp-73123',
    authDomain: 'momentumapp-73123.firebaseapp.com',
    storageBucket: 'momentumapp-73123.firebasestorage.app',
    measurementId: 'G-RN0MVYSP02',
});

const messaging = firebase.messaging();
