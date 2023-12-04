package jp.manse

import android.content.res.Configuration
import android.util.Log
import com.brightcove.player.pictureinpicture.PictureInPictureManager
import com.facebook.react.ReactActivity

abstract class BrightcoveReactActivity : ReactActivity() {
    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration?) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        try {
            hideShowActionBar(isInPictureInPictureMode)
            PictureInPictureManager.getInstance().onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        } catch (e: Exception) {
            Log.e(TAG, "PiP onPictureInPictureModeChanged Error: ${e.localizedMessage}")
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        try {
            PictureInPictureManager.getInstance().onUserLeaveHint()
        } catch (e: Exception) {
            Log.e(TAG, "PiP onUserLeaveHint Error: ${e.localizedMessage}")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            PictureInPictureManager.getInstance().unregisterActivity(this)
        } catch (e: Exception) {
            Log.e(TAG, "PiP unregisterActivity Error: ${e.localizedMessage}")
        }
    }

    private fun hideShowActionBar(isInPictureInPictureMode: Boolean) {
        if (isInPictureInPictureMode)
            supportActionBar?.hide();
        else
            supportActionBar?.show()
    }
    companion object {
        const val TAG = "BrightcoveReactActivity"
    }
}