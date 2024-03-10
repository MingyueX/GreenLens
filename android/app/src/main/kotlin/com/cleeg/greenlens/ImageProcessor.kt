package com.cleeg.greenlens

import android.graphics.BitmapFactory
import android.content.Context
import android.graphics.Bitmap
import org.pytorch.torchvision.TensorImageUtils
import com.chaquo.python.Python
import com.chaquo.python.PyObject
import org.pytorch.Tensor
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Canvas
import android.graphics.Paint
import android.util.Log

class ImageProcessor(private val context: Context) {

    private val TORCHVISION_NORM_MEAN_RGB = floatArrayOf(0.485f, 0.456f, 0.406f)
    private val TORCHVISION_NORM_STD_RGB = floatArrayOf(0.229f, 0.224f, 0.225f)
    private  val TAG = "ImageProcessor"

    fun byteArrayToBitmap(byteArray: ByteArray): Bitmap {
        return BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
    }

    fun convertToGrayscale(input: Bitmap): Bitmap {
        val bmpGrayscale = Bitmap.createBitmap(input.width, input.height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmpGrayscale)
        val paint = Paint()
        val cm = ColorMatrix()
        cm.setSaturation(0f)
        val f = ColorMatrixColorFilter(cm)
        paint.colorFilter = f
        canvas.drawBitmap(input, 0f, 0f, paint)
        return bmpGrayscale
    }

    fun getPreProcess(depthArr: List<Double>, rgbArr: ByteArray, depthWidth: Int, depthHeight: Int): Triple<Bitmap, Bitmap, Pair<Int, Int>> {

        val python = Python.getInstance()
        val pythonModule = python.getModule("improc_all")
        val doubleArray = depthArr.toDoubleArray()
        val result : List<PyObject> = pythonModule.callAttr("preprocess_images", doubleArray, rgbArr, depthWidth, depthHeight).asList()

        val rgbByteArray: ByteArray = result[0]!!.toJava(ByteArray::class.java)
        val img_rgb: Bitmap = byteArrayToBitmap(rgbByteArray)

//        val rgb = Bitmap.createBitmap(img_rgb.width, img_rgb.height, img_rgb.config)
//        val canvas = Canvas(rgb)
//        val paint = Paint()
//        val colorTransform = ColorMatrix()
//        colorTransform.set(floatArrayOf(0f, 0f, 1f, 0f, 0f, 0f, 1f, 0f, 0f, 0f, 1f, 0f, 0f, 0f, 0f))
//        paint.colorFilter = ColorMatrixColorFilter(colorTransform)
//        canvas.drawBitmap(img_rgb, 0f, 0f, paint)

        val depthPyList: ByteArray = result[1]!!.toJava(ByteArray::class.java)
        val img_depth: Bitmap = byteArrayToBitmap(depthPyList)

        // val depth = convertToGrayscale(img_depth)

        val gtWidth = img_depth.width
        val gtHeight = img_depth.height
        return Triple(img_rgb, img_depth, Pair(gtWidth, gtHeight))
    }

    fun preProcessImage(img_rgb: Bitmap, depth: Bitmap): Pair<Tensor, Tensor> {
        val resizedRGB = Bitmap.createScaledBitmap(img_rgb, 352, 352, true)
        val imageRgbTensor = TensorImageUtils.bitmapToFloat32Tensor(resizedRGB,
            TORCHVISION_NORM_MEAN_RGB, TORCHVISION_NORM_STD_RGB)

        val resizedDepth = Bitmap.createScaledBitmap(depth, 352, 352, true)
        // val depthTensor =  TensorImageUtils.bitmapToFloat32Tensor(resizedDepth, floatArrayOf(0.5f), floatArrayOf(0.5f))
        val width = resizedDepth.width
        val height = resizedDepth.height

        val depthArray = FloatArray(width * height)
        for (y in 0 until height) {
            for (x in 0 until width) {
                val pixel = resizedDepth.getPixel(x, y)
                val value = (pixel and 0xFF) / 255.0f
//                val normalizedValue = (value - 0.5f) / 0.5f
                depthArray[y * width + x] = value
            }
        }

        val depthTensor = Tensor.fromBlob(depthArray, longArrayOf(1, 1, height.toLong(), width.toLong()))

//        val depthArray = FloatArray(depthList.size) { idx -> depthList[idx] }
//        val depthTensor = Tensor.fromBlob(depthArray, longArrayOf(1, 1, 352, 352))

        Log.d(TAG, "depthTensorSize: ${depthTensor.shape().contentToString()}")
        Log.d(TAG, "imageRgbTensorSize: ${imageRgbTensor.shape().contentToString()}")

        return Pair(imageRgbTensor, depthTensor)
    }

    fun processImage(rgbArr: ByteArray, depthArr: List<Double>, depthWidth: Int, depthHeight: Int, focalLength: Double?): String {
        val pre = getPreProcess(depthArr, rgbArr, depthWidth, depthHeight)
        val gtWidth = pre.third.first
        val gtHeight = pre.third.second
        val tensors = preProcessImage(pre.first, pre.second)

        val pyTorchMobile = PyTorchMobile.getInstance(context)
        val outputTensor = pyTorchMobile.runInference(tensors.first, tensors.second)

        val outputArray = outputTensor.dataAsFloatArray

        val python = Python.getInstance()
        val pythonModule = python.getModule("improc_all")

        @Suppress("UNCHECKED_CAST")
        if (focalLength != null) {
            return pythonModule.callAttr("run", outputArray, gtWidth, gtHeight, focalLength / 3 * 2).toString()
        }
        return pythonModule.callAttr("run", outputArray, gtWidth, gtHeight).toString()
    }

    fun saveToFile(context: Context, filename: String, dataString: String) {
        context.openFileOutput(filename, Context.MODE_PRIVATE).use {
            it.write(dataString.toByteArray())
        }
    }

    fun getPreProcessDebug(depthArr: List<Double>, rgbArr: ByteArray, depthWidth: Int, depthHeight: Int): Triple<Bitmap, Bitmap, Pair<Int, Int>> {

        val python = Python.getInstance()
        val pythonModule = python.getModule("improc_all_debug")
        val doubleArray = depthArr.toDoubleArray()
        // save the doubleArray to phone
        val dataString = doubleArray.joinToString(separator = "\n") { it.toString() }
        saveToFile(context, "depth_info.txt", dataString)

        val result : List<PyObject> = pythonModule.callAttr("preprocess_images", doubleArray, rgbArr).asList()

        val rgbByteArray: ByteArray = result[0]!!.toJava(ByteArray::class.java)
        val img_rgb: Bitmap = byteArrayToBitmap(rgbByteArray)

        val depthPyList: ByteArray = result[1]!!.toJava(ByteArray::class.java)
        val img_depth: Bitmap = byteArrayToBitmap(depthPyList)

        val gtWidth = img_depth.width
        val gtHeight = img_depth.height
        return Triple(img_rgb, img_depth, Pair(gtWidth, gtHeight))
    }

    fun processImageDebug(rgbArr: ByteArray, depthArr: List<Double>, depthWidth: Int, depthHeight: Int): String {
        val pre = getPreProcessDebug(depthArr, rgbArr, depthWidth, depthHeight)
        val gtWidth = pre.third.first
        val gtHeight = pre.third.second
        val tensors = preProcessImage(pre.first, pre.second)

        // Save tensors to file
        saveToFile(context, "rgb_tensor.txt", tensors.first.dataAsFloatArray.joinToString(","))
        saveToFile(context, "depth_tensor.txt", tensors.second.dataAsFloatArray.joinToString(","))

        val pyTorchMobile = PyTorchMobile.getInstance(context)
//        val outputTensor = pyTorchMobile.runInference(tensors.first, tensors.second)
        val outputTensor = pyTorchMobile.runInference(tensors.first, tensors.second)

        val outputArray = outputTensor.dataAsFloatArray

        val python = Python.getInstance()
        val pythonModule = python.getModule("improc_all_debug")

        @Suppress("UNCHECKED_CAST")
        return pythonModule.callAttr("run", outputArray, gtWidth, gtHeight).toString()
    }

    fun processAfterAdjustment(depthArr: List<Double>, m1: Double, n1:Double, m2: Double, n2: Double, focalLength: Double?): String {
        val python = Python.getInstance()
        val pythonModule = python.getModule("improc_all")
        val doubleArray = depthArr.toDoubleArray()
        @Suppress("UNCHECKED_CAST")
        if (focalLength != null) {
            return pythonModule.callAttr("calculate_DBH_after_adjustment", doubleArray, m1, m2, n1, n2, focalLength / 3 * 2).toString()
        }
        return pythonModule.callAttr("calculate_DBH_after_adjustment", doubleArray, m1, m2, n1, n2).toString()
    }
}
