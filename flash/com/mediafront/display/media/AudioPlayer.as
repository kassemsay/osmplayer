﻿/** *  Copyright (c) 2010 Alethia Inc, *  http://www.alethia-inc.com *  Developed by Travis Tidwell | travist at alethia-inc.com  * *  License:  GPL version 3. * *  Permission is hereby granted, free of charge, to any person obtaining a copy *  of this software and associated documentation files (the "Software"), to deal *  in the Software without restriction, including without limitation the rights *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell *  copies of the Software, and to permit persons to whom the Software is *  furnished to do so, subject to the following conditions: *   *  The above copyright notice and this permission notice shall be included in *  all copies or substantial portions of the Software. *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN *  THE SOFTWARE. */package com.mediafront.display.media{   import com.mediafront.display.media.MediaPlayer;   import com.mediafront.display.media.MediaEvent;   import com.mediafront.display.media.IMedia;   import com.mediafront.utils.Utils;   import flash.display.*;   import flash.events.*;   import flash.media.*;   import flash.utils.*;   import flash.net.*;   public class AudioPlayer extends Sound implements IMedia   {      public function AudioPlayer( _debug:Boolean, _onMediaEvent:Function )      {         super();         debug = _debug;         onMediaEvent = _onMediaEvent;         context = new SoundLoaderContext(5*1000,true);      }      public function connect( stream:String ) : void      {         SoundMixer.stopAll();         onMediaEvent( MediaEvent.CONNECTED );      }      public function loadFile( file:String ) : void      {         removeEventListener( Event.SOUND_COMPLETE, audioUpdate );         removeEventListener( Event.ID3, audioUpdate );         removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);         addEventListener( Event.SOUND_COMPLETE, audioUpdate );         addEventListener( Event.ID3, audioUpdate );         addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);         position = 0;         duration = 0;         vol = 0.8;         loaded = false;         Utils.debug( "AudioPlayer: loadFile( " + file + ")", debug );         var request:URLRequest=new URLRequest(file);         request.requestHeaders.push( new URLRequestHeader("pragma", "no-cache") );         try {            super.load( request, context );         } catch (error:Error) {            Utils.debug("Unable to load " + file);         }      }      private function audioUpdate( e:Object ):void      {         switch ( e.type ) {            case Event.ID3 :               onMediaEvent( MediaEvent.META );               if( !loaded ) {                  loaded = true;                  playMedia();               }                             break;            case Event.SOUND_COMPLETE :               onMediaEvent( MediaEvent.COMPLETE );               break;         }      }      private function ioErrorHandler(event:Event):void      {      }      public function getVolume() : Number       {         if( channel ) {            return channel.soundTransform.volume;         }                  return 0;      }      public function setVolume(_vol:Number) : void      {         Utils.debug( "AudioPlayer: setVolume( " + _vol + ")", debug );                if (channel) {            var transform:SoundTransform = channel.soundTransform;            transform.volume = vol = _vol;            channel.soundTransform = transform;         }      }      private function stopChannel() : void      {         if ( channel ) {            channel.stop();         }         SoundMixer.stopAll();            }      public function playMedia( setPos:Number = -1 ) : void      {         var newPos = (setPos >= 0) ? setPos : position;         Utils.debug( "AudioPlayer: playMedia( " + newPos + ")", debug );         channel = super.play(newPos);         setVolume( vol );                channel.removeEventListener( Event.SOUND_COMPLETE, audioUpdate );         channel.addEventListener( Event.SOUND_COMPLETE, audioUpdate );         onMediaEvent( MediaEvent.PLAYING );      }      public function pauseMedia() : void      {         position = channel.position;         stopChannel();                Utils.debug( "AudioPlayer: pauseMedia( " + position + ")", debug );         onMediaEvent( MediaEvent.PAUSED );      }      public function stopMedia() : void      {         position = 0;         duration = 0;         vol = 0.8;         loaded = false;         stopChannel();                  // If we are still streaming a audio track, then close it.         try {            this.close();           }         catch( e:Error ) {            trace( e.toString() );         }                          Utils.debug( "AudioPlayer: stopMedia()", debug );         onMediaEvent( MediaEvent.STOPPED );      }      public function seekMedia( pos:Number ) : void      {         if ( channel) {            stopChannel();             Utils.debug( "AudioPlayer: seekMedia( " + pos + ")", debug );            playMedia((pos * 1000));         }      }      public function getDuration():Number      {         var _duration:Number = duration;         if( this.bytesLoaded >= this.bytesTotal ) {            duration = _duration = this.length / 1000;         }         else if( !duration && this.length && (this.bytesLoaded > 0) && (this.bytesTotal > 0) ) {            duration = _duration = (uint(this.length/2) / uint(this.bytesLoaded/2)) * (this.bytesTotal / 1000);         }                 return _duration;             }      public function getCurrentTime():Number      {         return (channel ? (channel.position / 1000) : 0);      }      public function getMediaBytesLoaded() : Number       {         return bytesLoaded;      }      public function getMediaBytesTotal() : Number       {         return bytesTotal;      }        public function getRatio():Number      {         return 0;      }        private var channel:SoundChannel;      private var context:SoundLoaderContext;      private var duration:Number = 0;      private var position:Number = 0;       private var loaded:Boolean = false;      private var debug:Boolean = false;      private var vol:Number = 0.8;      private var onMediaEvent:Function = null;   }}