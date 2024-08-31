// the download method is only supported for compile in web target

export 'download_main.dart'
    if (dart.library.js) 'download_web.dart'
    if (dart.library.io) 'download_all.dart';
