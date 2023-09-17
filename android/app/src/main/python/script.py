import io,os,sys,time,threading,ctypes,inspect,traceback,json

def serialize_to_json(value):
    if isinstance(value, (int, float, str, list, dict, bool, type(None))):
        return value
    # Add more custom serialization logic if needed
    return str(value)

def _async_raise(tid, exctype):
    tid = ctypes.c_long(tid)
    if not inspect.isclass(exctype):
        exctype = type(exctype)
    res = ctypes.pythonapi.PyThreadState_SetAsyncExc(tid, ctypes.py_object(exctype))
    if res == 0:
        raise ValueError("invalid thread id")
    elif res != 1:
        ctypes.pythonapi.PyThreadState_SetAsyncExc(tid, None)
        raise SystemError("Timeout Exception")

def stop_thread(thread):
    _async_raise(thread.ident, SystemExit)

def text_thread_run(code, result_container):
    try:
        env = {}
        exec(code, env, env)
        results = env.get('result', None)
        if isinstance(results, tuple):
            serialized_results = [serialize_to_json(item) for item in results]
        else:
            serialized_results = [serialize_to_json(results)]
        result_container[0] = json.dumps(serialized_results)
    except Exception as e:
        result_container[1] = e

#   This is the code to run Text functions...
def mainTextCode(code):
    global thread1
    result_container = [None, None]
    thread1 = threading.Thread(target=text_thread_run, args=(code, result_container),daemon=True)
    thread1.start()
    timeout = 45 # change timeout settings in seconds here...
    thread1_start_time = time.time()
    while thread1.is_alive():
        if time.time() - thread1_start_time > timeout:
            stop_thread(thread1)
            raise Exception(f"TimeoutError: Python code execution exceeded the timeout limit : {timeout}.")
        time.sleep(1)
    if result_container[1]:  # If there's an error
        raise result_container[1]
    elif result_container[0] is None:
        raise Exception("UnknownError: Python code did not return a result or raise an exception.")
    return result_container[0]
