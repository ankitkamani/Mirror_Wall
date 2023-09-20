import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mirror_wall/Providers/Bookmark%20Provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sp;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BookMarkProvider())
      ],
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mirror Wall',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'My Browser'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  InAppWebViewController? webViewController;
  TextEditingController search = TextEditingController();
  PullToRefreshController? pullToRefreshController;
  double progress = 0;
  int searchEngine = 1;
  String uri = 'https://www.google.co.in/';
  var subscription;

  @override
  void initState() {
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        webViewController?.reload();
      },
    );

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {});

    super.initState();
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bookPro = Provider.of<BookMarkProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(widget.title),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 1) {
                bookPro.getSp();
                // show bookmarks
                showModalBottomSheet(
                  shape: const UnderlineInputBorder(),
                  // isDismissible: false,
                  useSafeArea: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            color: Colors.black12,
                            height: 50,
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('DISMISS'),
                            ),
                          ),
                          Consumer<BookMarkProvider>(
                            builder: (context, bookProValue, child) {
                              return Expanded(
                                  child: bookProValue.bookmark.isEmpty
                                      ? Container(
                                          alignment: Alignment.center,
                                          child: const Text(
                                              'No any Bookmark yet...'),
                                        )
                                      : ListView.builder(
                                          itemCount:
                                              bookProValue.bookmark.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              onTap: () {
                                                setState(() {
                                                  webViewController?.loadUrl(
                                                      urlRequest: URLRequest(
                                                          url: Uri.parse(
                                                              bookProValue.bookmark[
                                                                          index]
                                                                      ['Url'] ??
                                                                  '')));
                                                });
                                                Navigator.pop(context);
                                              },
                                              title: Text(
                                                bookProValue.bookmark[index]
                                                        ['Title'] ??
                                                    '',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                bookProValue.bookmark[index]
                                                        ['Url'] ??
                                                    '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.close),
                                                onPressed: () {
                                                  bookProValue
                                                      .removeFromBookMark(
                                                          index);
                                                },
                                              ),
                                            );
                                          },
                                        ));
                            },
                          )
                        ],
                      ),
                    );
                  },
                );
              } else {
                //show search engines
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      alignment: Alignment.center,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile(
                            title: const Text(
                              'Google',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            value: 1,
                            groupValue: searchEngine,
                            onChanged: (value) {
                              setState(() {
                                searchEngine = value ?? 1;
                                uri = 'https://www.google.co.in/';
                                webViewController?.loadUrl(
                                    urlRequest:
                                        URLRequest(url: Uri.parse(uri)));
                                search.text = '';
                                Navigator.pop(context);
                              });
                            },
                          ),
                          RadioListTile(
                            title: const Text(
                              'Yahoo',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            value: 2,
                            groupValue: searchEngine,
                            onChanged: (value) {
                              setState(() {
                                searchEngine = value ?? 2;
                                uri = 'https://in.search.yahoo.com/';
                                webViewController?.loadUrl(
                                    urlRequest:
                                        URLRequest(url: Uri.parse(uri)));
                                search.text = '';
                                Navigator.pop(context);
                              });
                            },
                          ),
                          RadioListTile(
                            title: const Text(
                              'Bing',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            value: 3,
                            groupValue: searchEngine,
                            onChanged: (value) {
                              setState(() {
                                searchEngine = value ?? 3;
                                uri = 'https://www.bing.com/#!';
                                webViewController?.loadUrl(
                                    urlRequest:
                                        URLRequest(url: Uri.parse(uri)));
                                search.text = '';
                                Navigator.pop(context);
                              });
                            },
                          ),
                          RadioListTile(
                            title: const Text(
                              'Duck Duck Go',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            value: 4,
                            groupValue: searchEngine,
                            onChanged: (value) {
                              setState(() {
                                searchEngine = value ?? 4;
                                searchEngine = value ?? 3;
                                uri = 'https://duckduckgo.com/';
                                webViewController?.loadUrl(
                                    urlRequest:
                                        URLRequest(url: Uri.parse(uri)));
                                search.text = '';
                                Navigator.pop(context);
                              });
                            },
                          ),
                        ],
                      ),
                      title: const Center(child: Text('Search Engine')),
                    );
                  },
                );
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(value: 1, child: Text('All Bookmarks')),
                const PopupMenuItem(
                  value: 2,
                  child: Text('Search Engine'),
                ),
              ];
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<ConnectivityResult>(
                stream: Connectivity().onConnectivityChanged,
                builder: (context, snapshot) {
                  return snapshot.data != ConnectivityResult.none
                      ? InAppWebView(
                          onWebViewCreated: (controller) {
                            webViewController = controller;
                          },
                          initialUrlRequest: URLRequest(url: Uri.parse(uri)),
                          pullToRefreshController: pullToRefreshController,
                          onProgressChanged: (controller, progress) {
                            setState(() {
                              this.progress = progress / 100;
                            });
                          },
                        )
                      : Container(
                          alignment: Alignment.center,
                          child: const Text('No Internet Connection'),
                        );
                }),
          ),
          Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.all(8.0).copyWith(top: 0, bottom: 0),
                  child: TextField(
                      controller: search,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: 'Search or type web address',
                          suffixIcon: IconButton(
                              onPressed: () {
                                if (searchEngine == 1) {
                                  webViewController?.loadUrl(
                                      urlRequest: URLRequest(
                                          url: Uri.parse(
                                              'https://www.google.co.in/search?q=${search.text}')));
                                } else if (searchEngine == 2) {
                                  webViewController?.loadUrl(
                                      urlRequest: URLRequest(
                                          url: Uri.parse(
                                              'https://in.search.yahoo.com/search;_ylt=AwrKGhxiowZlYik7StK7HAx.;_ylc=?p=${search.text}')));
                                } else if (searchEngine == 3) {
                                  webViewController?.loadUrl(
                                      urlRequest: URLRequest(
                                          url: Uri.parse(
                                              'https://www.bing.com/search?q=${search.text}')));
                                } else if (searchEngine == 4) {
                                  webViewController?.loadUrl(
                                      urlRequest: URLRequest(
                                          url: Uri.parse(
                                              'https://duckduckgo.com/?t=h_&q=${search.text}')));
                                }
                              },
                              icon: const Icon(Icons.search)))),
                ),
                Visibility(
                    visible: progress != 1,
                    child: LinearProgressIndicator(value: progress)),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            webViewController?.loadUrl(
                                urlRequest: URLRequest(
                                    url: Uri.parse(
                                        'https://www.google.co.in/')));
                            search.text = '';
                            setState(() {});
                          },
                          icon: const Icon(Icons.home)),
                      IconButton(
                          onPressed: () async {
                            String url = '';
                            String title = '';
                            await webViewController?.getUrl().then((value) {
                              url = value.toString();
                            });
                            await webViewController?.getTitle().then((value) {
                              title = value.toString();
                            });
                            Map<String, String> map = {
                              'Title': title,
                              'Url': url
                            };
                            bookPro.addToBookMark(map);
                          },
                          icon: const Icon(Icons.bookmark_add_outlined)),
                      IconButton(
                          onPressed: () {
                            webViewController?.goBack();
                            setState(() {});
                          },
                          icon: const Icon(Icons.arrow_back_ios_new)),
                      IconButton(
                          onPressed: () {
                            webViewController?.reload();
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh)),
                      IconButton(
                          onPressed: () {
                            webViewController?.goForward();
                            setState(() {});
                          },
                          icon: const Icon(Icons.arrow_forward_ios_outlined))
                    ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
