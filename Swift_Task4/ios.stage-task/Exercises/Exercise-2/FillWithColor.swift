import Foundation

final class FillWithColor {

    // MARK: - Types
    struct RSPoint: Hashable {
        let row: Int
        let column: Int

        init(_ row: Int, _ column: Int) {
            self.row = row
            self.column = column
        }
    }

    // MARK: - Properties
    private var fillPoints: Set<RSPoint> = []

    // MARK: - Public methods
    public func fillWithColor(
        _ image: [[Int]],
        _ row: Int,
        _ column: Int,
        _ newColor: Int
    ) -> [[Int]] {

        guard !image.isEmpty,
              image.count <= 50,
              image.filter({ $0.count != image.first?.count }).isEmpty,
              image.filter({ !$0.filter({ $0 < 0}).isEmpty }).isEmpty,
              row >= 0, row < image.count,
              column >= 0, column < image.first?.count ?? 0,
              newColor < 65536
        else { return image }

        var newImage = image
        fillPoints.insert(.init(row, column))
        paintAdjacentElements(at: .init(row, column), in: &newImage)
        fillPoints.forEach { newImage[$0.row][$0.column] = newColor }
        return newImage
    }

    // MARK: - Private methods
    private func paintAdjacentElements(
        at point: RSPoint,
        in image: inout [[Int]]
    ) {
        let area: [RSPoint] = [
            .init(point.row, point.column - 1),
            .init(point.row, point.column + 1),
            .init(point.row - 1, point.column),
            .init(point.row + 1, point.column)
        ]
        .filter { $0.row < image.count && $0.row >= 0 && $0.column < image.first?.count ?? 1 && $0.column >= 0 }

        area.forEach { nearestPoint in
            if image[nearestPoint.row][nearestPoint.column] == image[point.row][point.column] {
                if fillPoints.insert(.init(nearestPoint.row, nearestPoint.column)).inserted {
                    paintAdjacentElements(at: nearestPoint, in: &image)
                }
            }
        }
    }
}
