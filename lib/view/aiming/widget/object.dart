// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pytorch_lite/pigeon.dart';

class ObjectRecogniz {
  double distance(
      ResultObjectDetection result,
      double zoomValue,
      int coustomFlagH,
      int coustomFlagW,
      int imageH,
      int imageW,
      double pixelRatio) {
    double imgHeight = imageH * result.rect.height;
    double imgWidth = imageW * result.rect.width;
    double resultHeight = 0.0;
    double removeRate = 0.0; // 삭감률

    // DPI=픽셀비율×160
    //cmToPixcel = 16.636; 샘플
    double dpi = pixelRatio * 160;
    double cmToPixel = 1 / 2.54 * dpi;
    double imageFlagRate = imgWidth / imgHeight;
    double flagRate = coustomFlagW / coustomFlagH;
    double flagMaxRate = flagRate;
    double flagMinRate = 0.25;
    List<double> flagRange = [];
    int rangeStep = 100;
    int flagRangeStep = 0;
    double bTpyeDistance = 0;
    double resultPixel = 0; // 촬영된 모바일이 1m 일때 차치 할 예상 픽셀 수 (세로)
    var resultStepDistance = 0.0;
    double stepData = 0.0;
    var transRate = imageH / 1920; // 모바일 별  567 변환 비율
    double initFlagHeight = 567;
    cmToPixel = 16.636;
    var varLate = 0.0;
    if (coustomFlagH > 38) {
      int a = coustomFlagH - 38;
      resultPixel = (initFlagHeight + (cmToPixel * a));
    } else if (coustomFlagH == 38) {
      resultPixel = initFlagHeight;
    } else {
      int a = 38 - coustomFlagH;
      resultPixel = (initFlagHeight - (cmToPixel * a));
    }

    resultPixel = resultPixel * transRate;

    double flagRateForlate = sqrt(
        (coustomFlagW * coustomFlagW) + (coustomFlagH * coustomFlagH)); //대각선

    varLate = ((flagRateForlate - coustomFlagH) / flagRateForlate) * 100;

    varLate = varLate - 12;

    for (int i = 0; i < rangeStep; i++) {
      flagRange
          .add(flagMaxRate - ((flagMaxRate - flagMinRate) / rangeStep) * i);
    }

    for (int i = 0; i < flagRange.length - 1; i++) {
      if (imageFlagRate <= flagRange[i] && imageFlagRate > flagRange[i + 1]) {
        flagRangeStep = i;
        break;
      }
    }

    if (flagRangeStep == 0) {
      rangeStep = flagRangeStep - 5;
    } else {
      rangeStep = flagRangeStep;
    }

    stepData = (100 - (rangeStep * (varLate / rangeStep))) / 100;
    removeRate = ((1 - stepData) / 100);
    removeRate = 1 - (removeRate * flagRangeStep);
    resultHeight = imgHeight * removeRate;
    bTpyeDistance = ((zoomValue * resultPixel) / (resultHeight));

    //    int coustomFlagH,
    //   int coustomFlagW,

    print("d.fourlab phone ================================================");
    print("d.fourlab phone cmToPixel : $cmToPixel");
    print("d.fourlab phone removeRate : $removeRate");
    print("d.fourlab phone zoomValue : $zoomValue");
    print("d.fourlab phone imageW : $imageW");
    print("d.fourlab phone imageH : $imageH");
    print("d.fourlab phone coustomFlagH : $coustomFlagH");
    print("d.fourlab phone coustomFlagW : $coustomFlagW");
    print("d.fourlab phone resultFlagPixel : $resultHeight");
    print("d.fourlab phone resultPixel : $resultPixel");
    print("d.fourlab phone bTpyeDistance : $bTpyeDistance");
    print("d.fourlab phone ================================================");
    resultStepDistance = bTpyeDistance;

    return resultStepDistance;
  }
}

class ObjectRecognizFov {
  List<double> distance(
    BuildContext context,
      File imagePath,
      ResultObjectDetection result,
      double zoomValue,
      int coustomFlagH,
      int coustomFlagW,
      int imageH,
      int imageW,
      double pixelRatio,
      int changeData) {
    print("d.fourlab phone coustomFlagH : $coustomFlagH");
    print("d.fourlab phone coustomFlagH : $coustomFlagH");
    int tempW = coustomFlagH;
    int tempH = coustomFlagW;
    coustomFlagH = 38;
    coustomFlagW = tempW;

    //analyzeImage(context,imagePath, result,imageH ,imageW);

    double imgHeight = imageH * result.rect.height;
    double imgWidth = imageW * result.rect.width;
    double resultHeight = 0.0;
    double removeRate = 0.0; // 삭감률

    // DPI=픽셀비율×160
    //cmToPixcel = 16.636; 샘플
    double dpi = pixelRatio * 160;
    double cmToPixel = 1 / 2.54 * dpi;
    double imageFlagRate = imgWidth / imgHeight;
    double flagRate = coustomFlagW / coustomFlagH;
    double flagMaxRate = flagRate;
    double flagMinRate = 0.1;
    List<double> flagRange = [];
    int rangeStep = 100;
    int flagRangeStep = 0;
    double bTpyeDistance = 0;
    double resultPixel = 0; // 촬영된 모바일이 1m 일때 차치 할 예상 픽셀 수 (세로)
    var resultStepDistance = 0.0;
    double stepData = 0.0;
    var transRate = imageH / 1920; // 모바일 별  567 변환 비율
    double initFlagHeight = 567;
    //cmToPixel = cmToPixel / zoomValue;

    cmToPixel = 16.636;

    //transRate = transRate * 567;  // 1920 일 때 1m 픽셀 수 567
    var varLate = 0.0;
    if (coustomFlagH > 38) {
      int a = coustomFlagH - 38;
      resultPixel = (initFlagHeight + (cmToPixel * a));
    } else if (coustomFlagH == 38) {
      resultPixel = initFlagHeight;
    } else {
      int a = 38 - coustomFlagH;
      resultPixel = (initFlagHeight - (cmToPixel * a));
    }

    resultPixel = resultPixel * transRate;

    double flagRateForlate = sqrt(
        (coustomFlagW * coustomFlagW) + (coustomFlagH * coustomFlagH)); //대각선

    varLate = ((flagRateForlate - coustomFlagH) / flagRateForlate) * 100;

    varLate = varLate;

    for (int i = 0; i < rangeStep; i++) {
      flagRange
          .add(flagMaxRate - ((flagMaxRate - flagMinRate) / rangeStep) * i);
    }

    for (int i = 0; i < flagRange.length - 1; i++) {
      if (imageFlagRate <= flagRange[i] && imageFlagRate > flagRange[i + 1]) {
        flagRangeStep = i;
        break;
      }
    }

    if (flagRangeStep == 0) {
      rangeStep = flagRangeStep - 5;
    } else {
      rangeStep = flagRangeStep;
    }

    stepData = (100 - (rangeStep * (varLate / rangeStep))) / 100;
    removeRate = ((1 - stepData) / 100);
    removeRate = 1 - (removeRate * flagRangeStep);

    if (imageFlagRate > 0.4 && imageFlagRate < 0.6) {
      removeRate = removeRate + 0.05;
    } else if (imageFlagRate >= 0.6 && imageFlagRate < 0.7) {
      // removeRate = removeRate + 0.20;
    }
    resultHeight = imgHeight * (removeRate);
    bTpyeDistance = ((zoomValue * resultPixel) / (resultHeight));

    print("d.fourlab phone ================================================");
    print("d.fourlab phone flagRange : $flagRange");
    print("d.fourlab phone imageFlagRate : $imageFlagRate");
    print("d.fourlab phone rangeStep : $rangeStep");
    print("d.fourlab phone stepData : $stepData");
    print("d.fourlab phone cmToPixel : $cmToPixel");
    print("d.fourlab phone removeRate : $removeRate");
    print("d.fourlab phone zoomValue : $zoomValue");
    print("d.fourlab phone imageW : $imageW");
    print("d.fourlab phone imageH : $imageH");
    print("d.fourlab phone coustomFlagH : $coustomFlagH");
    print("d.fourlab phone coustomFlagW : $coustomFlagW");
    print("d.fourlab phone resultFlagPixel : $resultHeight");
    print("d.fourlab phone detactimgHeight : $imgHeight");
    print("d.fourlab phone resultPixel : $resultPixel");
    print("d.fourlab phone bTpyeDistance : $bTpyeDistance");

    resultStepDistance = bTpyeDistance;

    ////////////////////////////////
    var objectHeigthInImage = imgHeight;
    if (imageFlagRate < 0.7) {
      objectHeigthInImage = resultHeight;
    }
    var objectRealHeight = coustomFlagH * 10;
    //var objectHeigthInImage = resultHeight;

    var imageHeigth = imageH;
    var fov = 78;
    var fovRad = fov * math.pi / 180;
    var tan = math.tan(((objectHeigthInImage / imageHeigth) * (fovRad)) / 2);
    var fovdistance = (objectRealHeight / (2 * tan)) / 1000;
    fovdistance = fovdistance * zoomValue;

    print("d.fourlab tan : $tan");
    print("d.fourlab fovdistance : $fovdistance");
    print("d.fourlab phone ================================================");
    return [fovdistance + changeData ,imageFlagRate];
  }
}

void analyzeImage(
  BuildContext context,
  File imageData,
  ResultObjectDetection result,
  int imageH ,
  int imageW
) {
 // Uint8List를 Image 객체로 변환
  img.Image? image = img.decodeImage(imageData.readAsBytesSync());

  // 객체 감지 결과에서 좌표 및 크기 계산
  int x = (imageW * result.rect.left).toInt();
  int y = (imageH * result.rect.top).toInt();
  int width = (imageW * result.rect.width).toInt();
  int height = (imageH * result.rect.height).toInt();

  // 영역 추출
  img.Image region = img.copyCrop(
    image!, // 원본 이미지
    x: x, // 시작 좌표 x
    y: y, // 시작 좌표 y
    width: width, // 자를 영역의 너비
    height: height // 자를 영역의 높이
  );



 var data =  analyzeVerticalLineColors(region);
print(data);
var resultString = "단일기입니다.";
  if(data.length>1)
  {
resultString = "체크기입니다.";
  }
  
  Uint8List regionBytes = Uint8List.fromList(img.encodePng(region));

  Future.delayed(Duration(milliseconds: 1000), () {
    showDialog(
      context: context, // context를 전달
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('깃발 종류 분석'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // 내용이 넘치지 않도록
            children: [
              Image.memory(regionBytes),
              SizedBox(height: 10),
              Text(
                resultString,
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  });

}


// 색상의 유사성을 판단하는 함수
bool isColorSimilar(int color1, int color2, int tolerance) {
  int r1 = (color1 >> 16) & 0xFF;
  int g1 = (color1 >> 8) & 0xFF;
  int b1 = color1 & 0xFF;

  int r2 = (color2 >> 16) & 0xFF;
  int g2 = (color2 >> 8) & 0xFF;
  int b2 = color2 & 0xFF;

  return (r1 - r2).abs() <= tolerance &&
         (g1 - g2).abs() <= tolerance &&
         (b1 - b2).abs() <= tolerance;
}

// 가장 빈번한 색상 그룹을 찾기 위한 함수
int findMostCommonColorGroup(Map<int, int> colorCount, int tolerance) {
  int maxCount = 0;
  int mostCommonColorInt = 0;

  colorCount.forEach((color, count) {
    int currentCount = count;

    colorCount.forEach((otherColor, otherCount) {
      // 색상의 유사성을 판단하여 색상이 유사하면 count를 추가합니다.
      if (isColorSimilar(color, otherColor, tolerance)) {
        currentCount += otherCount;
      }
    });

    // 최대 빈도를 가진 색상 그룹을 찾습니다.
    if (currentCount > maxCount) {
      maxCount = currentCount;
      mostCommonColorInt = color;
    }
  });

  return mostCommonColorInt;
}



List<String> analyzeVerticalLineColors(img.Image region) {
    // 크롭된 영역의 중간 x 좌표 계산
    int middleX = region.width ~/ 2;

    // 색상 종류 카운팅을 위한 Map
    Map<String, int> colorCategoryCount = {
        'red': 0,
        'orange': 0,
        'yellow': 0,
        'green': 0,
        'blue': 0,
        'indigo': 0,
        'violet': 0,
        'black': 0,
        'white': 0
    };

    // 세로선에 있는 픽셀들을 순차적으로 추출하고 색상 종류를 구분합니다.
    for (int y = 0; y < (region.height/3)*2; y++) {
        // 픽셀의 색상 값을 가져옵니다.
        img.Pixel pixel = region.getPixel(middleX, y);

    // RGB 값을 int로 변환
    int red = pixel.r.toInt(); // int 타입으로 변환
    int green = pixel.g.toInt(); // int 타입으로 변환
    int blue = pixel.b.toInt(); // int 타입으로 변환

    // 색상 계열을 판단합니다.
    String colorCategory = categorizeColor(red, green, blue);
 print('r: $red, g: $green , b: $blue , colorCategory $colorCategory'  );
    // 해당 색상 계열 카운팅
        colorCategoryCount[colorCategory] = (colorCategoryCount[colorCategory] ?? 0) + 1;
    }

  // 각 색상 계열의 카운팅 결과 출력
  print('세로선의 각 색상 계열 카운팅 결과:');
  colorCategoryCount.forEach((colorCategory, count) {
    print('Color Category: $colorCategory, Count: $count');
  });

    // 상위 2가지 색 카테고리를 얻고 조건을 체크
    List<String> top2Categories = getTop2ColorCategories(region, colorCategoryCount);

    // 최종 결과 출력
    print('최종 선택된 상위 2가지 색 카테고리: $top2Categories');
    return top2Categories;
 
}
List<String> getTop2ColorCategories(img.Image region, Map<String, int> colorCategoryCount) {
    // region.height/3의 30% 계산
    double threshold = (region.height / 3) * 0.3;

    // colorCategoryCount 맵을 내림차순으로 정렬
    List<MapEntry<String, int>> sortedCategories = colorCategoryCount.entries.toList();
    sortedCategories.sort((a, b) => b.value.compareTo(a.value));

    // 상위 2가지 색 카테고리 선택
    List<String> top2Categories = [];
    for (var entry in sortedCategories) {
        if (top2Categories.length < 2) {
            // 카운팅 비율이 threshold 이상인지 확인
            if (entry.value >= threshold) {
                top2Categories.add(entry.key);
            }
        } else {
            break;
        }
    }

    // 결과에서 'black' 색상 카테고리를 제외
    top2Categories.removeWhere((colorCategory) => colorCategory == 'black');

    return top2Categories;
}
// 색상을 색상 계열로 구분하는 함수
String categorizeColor(int r, int g, int b) {
    // 빨주노초파남보검정흰색 계열에 따라 RGB 값에 대한 기준을 지정할 수 있습니다.
    if (r > 200 && g < 220 && b < 220) {
        return 'red';
    } else if (r > 200 && g > 100 && b < 100) {
        return 'orange';
    } else if (r > 200 && g > 200 && b < 100) {
        return 'yellow';
    } else if (g > 200 && r < 100 && b < 100) {
        return 'green';
    } else if (b > 200 && g < 100 && r < 100) {
        return 'blue';
    }  else if (b > 200 && g < 100 && r > 100) {
        return 'violet';
    } else if (r < 100 && g < 100 && b < 100) {
        return 'black';
    } else if (r > 200 && g > 200 && b > 200) {
        return 'white';
    }
    
    // 위의 기준에 해당하지 않는 경우 기본값으로 검정색을 반환할 수 있습니다.
    return 'black';
}