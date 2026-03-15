import 'package:dart_backend/utils/crud_util.dart';
import 'package:test/test.dart';

void main() {
  group('CrudUtil', () {
    group('pageParams', () {
      test('should return correct params for valid page and size', () {
        final result = CrudUtil.pageParams(1, 10);
        
        expect(result['limit'], 10);
        expect(result['offset'], 0);
      });

      test('should return correct offset for page 2', () {
        final result = CrudUtil.pageParams(2, 10);
        
        expect(result['limit'], 10);
        expect(result['offset'], 10);
      });

      test('should return correct offset for page 3', () {
        final result = CrudUtil.pageParams(3, 20);
        
        expect(result['limit'], 20);
        expect(result['offset'], 40);
      });

      test('should default to page 1 when page is less than 1', () {
        final result = CrudUtil.pageParams(0, 10);
        
        expect(result['limit'], 10);
        expect(result['offset'], 0);
      });

      test('should default to page 1 when page is negative', () {
        final result = CrudUtil.pageParams(-5, 10);
        
        expect(result['limit'], 10);
        expect(result['offset'], 0);
      });

      test('should default to size 10 when size is less than 1', () {
        final result = CrudUtil.pageParams(1, 0);
        
        expect(result['limit'], 10);
        expect(result['offset'], 0);
      });

      test('should default to size 10 when size is negative', () {
        final result = CrudUtil.pageParams(1, -5);
        
        expect(result['limit'], 10);
        expect(result['offset'], 0);
      });

      test('should handle large page numbers', () {
        final result = CrudUtil.pageParams(100, 10);
        
        expect(result['limit'], 10);
        expect(result['offset'], 990);
      });

      test('should handle large size numbers', () {
        final result = CrudUtil.pageParams(1, 100);
        
        expect(result['limit'], 100);
        expect(result['offset'], 0);
      });

      test('should return correct offset calculation', () {
        final result = CrudUtil.pageParams(5, 25);
        
        expect(result['limit'], 25);
        expect(result['offset'], 100);
      });

      test('should handle page 1 with different sizes', () {
        final result = CrudUtil.pageParams(1, 5);
        
        expect(result['limit'], 5);
        expect(result['offset'], 0);
      });

      test('should handle size 1', () {
        final result = CrudUtil.pageParams(10, 1);
        
        expect(result['limit'], 1);
        expect(result['offset'], 9);
      });
    });

    group('pageResult', () {
      test('should return correct page result structure', () {
        final result = CrudUtil.pageResult(
          page: 1,
          size: 10,
          total: 100,
          list: [{'id': 1, 'name': 'test'}],
        );
        
        expect(result['page'], 1);
        expect(result['size'], 10);
        expect(result['total'], 100);
        expect(result['pages'], 10);
        expect(result['list'], [{'id': 1, 'name': 'test'}]);
      });

      test('should calculate pages correctly when total is divisible by size', () {
        final result = CrudUtil.pageResult(
          page: 1,
          size: 10,
          total: 100,
          list: [],
        );
        
        expect(result['pages'], 10);
      });

      test('should calculate pages correctly when total is not divisible by size', () {
        final result = CrudUtil.pageResult(
          page: 1,
          size: 10,
          total: 105,
          list: [],
        );
        
        expect(result['pages'], 11);
      });

      test('should calculate pages correctly for small total', () {
        final result = CrudUtil.pageResult(
          page: 1,
          size: 10,
          total: 5,
          list: [],
        );
        
        expect(result['pages'], 1);
      });

      test('should calculate pages correctly for total equals size', () {
        final result = CrudUtil.pageResult(
          page: 1,
          size: 10,
          total: 10,
          list: [],
        );
        
        expect(result['pages'], 1);
      });

      test('should calculate pages correctly for total just over size', () {
        final result = CrudUtil.pageResult(
          page: 1,
          size: 10,
          total: 11,
          list: [],
        );
        
        expect(result['pages'], 2);
      });

      test('should handle empty list', () {
        final result = CrudUtil.pageResult(
          page: 1,
          size: 10,
          total: 0,
          list: [],
        );
        
        expect(result['list'], isEmpty);
        expect(result['pages'], 0);
      });

      test('should handle list with multiple items', () {
        final list = [
          {'id': 1, 'name': 'item1'},
          {'id': 2, 'name': 'item2'},
          {'id': 3, 'name': 'item3'},
        ];
        final result = CrudUtil.pageResult(
          page: 1,
          size: 10,
          total: 100,
          list: list,
        );
        
        expect(result['list'], hasLength(3));
        expect(result['list'][0]['id'], 1);
        expect(result['list'][2]['name'], 'item3');
      });

      test('should handle large total values', () {
        final result = CrudUtil.pageResult(
          page: 1,
          size: 10,
          total: 1000000,
          list: [],
        );
        
        expect(result['pages'], 100000);
      });

      test('should handle different page numbers in result', () {
        final result = CrudUtil.pageResult(
          page: 5,
          size: 20,
          total: 200,
          list: [],
        );
        
        expect(result['page'], 5);
        expect(result['size'], 20);
        expect(result['total'], 200);
        expect(result['pages'], 10);
      });

      test('should handle size 1 with large total', () {
        final result = CrudUtil.pageResult(
          page: 1,
          size: 1,
          total: 100,
          list: [],
        );
        
        expect(result['pages'], 100);
      });

      test('should handle list with null values', () {
        final list = [
          {'id': 1, 'name': null},
          {'id': 2, 'name': 'test'},
        ];
        final result = CrudUtil.pageResult(
          page: 1,
          size: 10,
          total: 2,
          list: list,
        );
        
        expect(result['list'], hasLength(2));
        expect(result['list'][0]['name'], isNull);
      });

      test('should handle list with complex objects', () {
        final list = [
          {
            'id': 1,
            'user': {'name': 'test', 'email': 'test@example.com'},
            'tags': ['tag1', 'tag2']
          },
        ];
        final result = CrudUtil.pageResult(
          page: 1,
          size: 10,
          total: 1,
          list: list,
        );
        
        expect(result['list'][0]['user']['name'], 'test');
        expect(result['list'][0]['tags'], ['tag1', 'tag2']);
      });
    });

    group('integration tests', () {
      test('should work together for typical pagination scenario', () {
        final page = 2;
        final size = 10;
        final total = 25;
        
        final params = CrudUtil.pageParams(page, size);
        expect(params['limit'], 10);
        expect(params['offset'], 10);
        
        final result = CrudUtil.pageResult(
          page: page,
          size: size,
          total: total,
          list: List.generate(10, (i) => {'id': i + 11}),
        );
        
        expect(result['page'], 2);
        expect(result['size'], 10);
        expect(result['total'], 25);
        expect(result['pages'], 3);
        expect(result['list'], hasLength(10));
      });

      test('should handle last page scenario', () {
        final page = 3;
        final size = 10;
        final total = 25;
        
        final params = CrudUtil.pageParams(page, size);
        expect(params['limit'], 10);
        expect(params['offset'], 20);
        
        final result = CrudUtil.pageResult(
          page: page,
          size: size,
          total: total,
          list: List.generate(5, (i) => {'id': i + 21}),
        );
        
        expect(result['page'], 3);
        expect(result['size'], 10);
        expect(result['total'], 25);
        expect(result['pages'], 3);
        expect(result['list'], hasLength(5));
      });

      test('should handle single page scenario', () {
        final page = 1;
        final size = 10;
        final total = 5;
        
        final params = CrudUtil.pageParams(page, size);
        expect(params['limit'], 10);
        expect(params['offset'], 0);
        
        final result = CrudUtil.pageResult(
          page: page,
          size: size,
          total: total,
          list: List.generate(5, (i) => {'id': i + 1}),
        );
        
        expect(result['page'], 1);
        expect(result['size'], 10);
        expect(result['total'], 5);
        expect(result['pages'], 1);
        expect(result['list'], hasLength(5));
      });
    });

    group('edge cases', () {
      test('should handle zero total', () {
        final result = CrudUtil.pageResult(
          page: 1,
          size: 10,
          total: 0,
          list: [],
        );
        
        expect(result['total'], 0);
        expect(result['pages'], 0);
        expect(result['list'], isEmpty);
      });

      test('should handle very large page numbers', () {
        final params = CrudUtil.pageParams(10000, 10);
        expect(params['offset'], 99990);
      });

      test('should handle very large size numbers', () {
        final params = CrudUtil.pageParams(1, 10000);
        expect(params['limit'], 10000);
        expect(params['offset'], 0);
      });

      test('should handle boundary values', () {
        final params = CrudUtil.pageParams(1, 1);
        expect(params['limit'], 1);
        expect(params['offset'], 0);
        
        final result = CrudUtil.pageResult(
          page: 1,
          size: 1,
          total: 1,
          list: [{'id': 1}],
        );
        
        expect(result['pages'], 1);
      });
    });
  });
}
