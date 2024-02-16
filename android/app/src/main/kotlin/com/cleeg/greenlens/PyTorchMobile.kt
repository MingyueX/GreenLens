package com.cleeg.greenlens

import android.content.Context
import org.pytorch.IValue
import org.pytorch.LiteModuleLoader
import org.pytorch.Module
import org.pytorch.Tensor
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class PyTorchMobile private constructor(context: Context) {

    private val module: Module

    init {
        module = LiteModuleLoader.load(assetFilePath(context, "BBSNet_mobile_optimized.ptl"))
    }

    private fun assetFilePath(context: Context, assetName: String): String {
        val fileAsset = File(context.filesDir, assetName)
        if (fileAsset.exists() && fileAsset.length() > 0) {
            return fileAsset.absolutePath
        }

        try {
            context.assets.open(assetName).use { inputStream ->
                FileOutputStream(fileAsset).use { os ->
                    val buffer = ByteArray(4 * 1024)
                    var read: Int
                    while (inputStream.read(buffer).also { read = it } != -1) {
                        os.write(buffer, 0, read)
                    }
                    os.flush()
                }
            }
            return fileAsset.absolutePath
        } catch (e: IOException) {
            throw RuntimeException("Error processing asset $assetName to file path")
        }
    }

    fun runInference(imageRgbTensor: Tensor, imgDepthTensor: Tensor): Tensor {
        val outputs = module.forward(IValue.from(imageRgbTensor), IValue.from(imgDepthTensor)).toTuple()
        return outputs[1].toTensor()
    }

    companion object {
        @Volatile
        private var instance: PyTorchMobile? = null

        fun getInstance(context: Context): PyTorchMobile {
            return instance ?: synchronized(this) {
                instance ?: PyTorchMobile(context).also { instance = it }
            }
        }
    }
}
