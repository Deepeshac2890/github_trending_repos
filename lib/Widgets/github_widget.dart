import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:github_trending_repos/Constants/assets_constants.dart';
import 'package:github_trending_repos/Constants/string_constants.dart';
import 'package:github_trending_repos/Model/github_model.dart';

class GithubItem extends StatefulWidget {
  const GithubItem({Key? key, required this.repo}) : super(key: key);
  final Items repo;

  @override
  _GithubItemState createState() => _GithubItemState();
}

class _GithubItemState extends State<GithubItem> {
  bool isExpanded = false;

  Widget buildExpandedWidget() {
    return FadeIn(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeIn,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Align(
              alignment: AlignmentDirectional.topCenter,
              child: Image.asset(
                catImageAsset,
                height: 50,
                width: 50,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(ownerNameString),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    widget.repo.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    widget.repo.description != null
                        ? widget.repo.description
                        : noDescriptionError,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Colors.black,
                            size: 10,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(widget.repo.language != null
                              ? widget.repo.language
                              : noLanguageError),
                        ],
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            starIconAsset,
                            height: 15,
                            width: 15,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(widget.repo.watchersCount.toString()),
                        ],
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            forkIconAsset,
                            height: 15,
                            width: 15,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(widget.repo.forksCount.toString()),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCollapsedWidget() {
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Image.asset(
              catImageAsset,
              height: 50,
              width: 50,
            ),
            const SizedBox(
              width: 4,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(ownerNameString),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.repo.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            const Expanded(
                child: SizedBox(
              width: 100,
            ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        highlightColor: Colors.lightBlueAccent,
        splashColor: Colors.red,
        child: ExpandableCardContainer(
          isExpanded: isExpanded,
          expandedChild: buildExpandedWidget(),
          collapsedChild: buildCollapsedWidget(),
        ),
      ),
    );
  }
}

class ExpandableCardContainer extends StatefulWidget {
  final bool isExpanded;
  final Widget collapsedChild;
  final Widget expandedChild;

  const ExpandableCardContainer(
      {required this.isExpanded,
      required this.collapsedChild,
      required this.expandedChild});

  @override
  _ExpandableCardContainerState createState() =>
      _ExpandableCardContainerState();
}

class _ExpandableCardContainerState extends State<ExpandableCardContainer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: widget.isExpanded ? widget.expandedChild : widget.collapsedChild,
    );
  }
}
