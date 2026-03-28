import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late double screenHeight;
  PageController scrollController = PageController();

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        children: [
          _banner(),
          Container(height: 1500, color: Theme.of(context).colorScheme.primary),
          Text(
            'Welcome to Flex Printing Home Page',
            style: TextStyle(fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _banner() {
    return Container(
      height: screenHeight - 100,
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.only(left: 50.0, right: 50, top: 60),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                mainAxisAlignment: .spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'DIGITAL\n',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 135,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        TextSpan(
                          text: 'PRINTING MACHINERY\nSUPPLER.',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 43,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  UiHelper.button(
                    callback: () {},
                    color: Colors.black,
                    filled: true,
                    borderRadius: 50,
                    child: Text(
                      "Learn More",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 34,
                      ),
                    ),
                  ),
                  Text("ONE DOOR SOLUTION", style: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 43,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  )
                ],
              ),
            ),
            Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(1000),
                    topRight: Radius.circular(1000),
                  ),
                  child: Container(
                    padding: EdgeInsets.only(top: 10,left:10,right:10),
                    decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      Colors.white,       // middle
                      Color(0xFFBDBDBD),  // outside grey
                    ],
                    stops: [0.0, 1.0],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 5,
                    ),
                    left: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 5,
                    ),
                    right: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 5,
                    ),
                    bottom: BorderSide.none,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(1000),
                    topRight: Radius.circular(1000),
                  ),
                                ),
                    child: Column(
                      children: [
                        Expanded(
                            child: Center(
                              child: PageView.builder(
                                controller: scrollController,
                                itemCount: 10,
                                  itemBuilder: (context, index) {
                                    return Center(
                                        child: Text('Item ${index+1}', style: TextStyle(color: Colors.black,fontSize: 50),)
                                    );
                                  }
                              ),
                            )
                        ),
                        SizedBox(
                          height: 55,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    scrollController.previousPage(duration: Duration(seconds: 1), curve: Curves.easeIn);
                                  },
                                  iconSize: 30,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black, // icon color
                                    shape: const CircleBorder(),
                                  ),
                                  icon: const Icon(Icons.arrow_back_ios_rounded),
                                ),
                                Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 35),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(100)
                                  )
                                )),
                                IconButton(
                                  onPressed: () {
                                    scrollController.nextPage(duration: Duration(seconds: 1), curve: Curves.easeIn);
                                  },
                                  iconSize: 30,
                                  style: IconButton.styleFrom(

                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black, // icon color
                                    shape: const CircleBorder(),
                                  ),
                                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30)
                      ],
                    ),
                              ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
