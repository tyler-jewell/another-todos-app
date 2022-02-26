import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

class FakeTodo extends Fake implements Todo {}

void main() {
  final mockTodos = [
    const Todo(
      id: '1',
      title: 'title 1',
      description: 'description 1',
    ),
    const Todo(
      id: '2',
      title: 'title 2',
      description: 'description 2',
    ),
    const Todo(
      id: '3',
      title: 'title 3',
      description: 'description 3',
      isComplete: true,
    ),
  ];

  group('TodosOverviewBloc', () {
    late TodosRepository todosRepository;

    setUpAll(() {
      registerFallbackValue(FakeTodo());
    });

    setUp(() {
      todosRepository = MockTodosRepository();
      when(
        () => todosRepository.todos(),
      ).thenAnswer((_) => Stream.value(mockTodos));
      when(() => todosRepository.updateTodo(any())).thenAnswer((_) async {});
    });

    TodosOverviewBloc buildBloc() {
      return TodosOverviewBloc(todosRepository: todosRepository);
    }

    group('constructor', () {
      test('works properly', () => expect(buildBloc, returnsNormally));

      test('has correct initial state', () {
        expect(
          buildBloc().state,
          equals(const TodosOverviewState()),
        );
      });
    });

    group('TodosOverviewSubscriptionRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'starts listening to repository getTodos stream',
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewSubscriptionRequested()),
        verify: (_) {
          verify(() => todosRepository.todos).called(1);
        },
      );

      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'emits state with updated status and todos '
        'when repository getTodos stream emits new todos',
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewSubscriptionRequested()),
        expect: () => [
          const TodosOverviewState(
            status: TodosOverviewStatus.loading,
          ),
          TodosOverviewState(
            status: TodosOverviewStatus.success,
            todos: mockTodos,
          ),
        ],
      );

      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'emits state with failure status '
        'when repository getTodos stream emits error',
        setUp: () {
          when(
            () => todosRepository.todos(),
          ).thenAnswer((_) => Stream.error(Exception('oops')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewSubscriptionRequested()),
        expect: () => [
          const TodosOverviewState(status: TodosOverviewStatus.loading),
          const TodosOverviewState(status: TodosOverviewStatus.failure),
        ],
      );
    });

    group('TodosOverviewTodoSaved', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'saves todo using repository',
        build: buildBloc,
        act: (bloc) => bloc.add(TodosOverviewTodoSaved(mockTodos.first)),
        verify: (_) {
          verify(() => todosRepository.updateTodo(mockTodos.first)).called(1);
        },
      );
    });

    group('TodosOverviewTodoDeleted', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'deletes todo using repository',
        setUp: () {
          when(
            () => todosRepository.deleteTodo(any()),
          ).thenAnswer((_) async {});
        },
        build: buildBloc,
        seed: () => TodosOverviewState(todos: mockTodos),
        act: (bloc) => bloc.add(TodosOverviewTodoDeleted(mockTodos.first)),
        verify: (_) {
          verify(
            () => todosRepository.deleteTodo(mockTodos.first),
          ).called(1);
        },
      );
    });

    group('TodosOverviewUndoDeletionRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'restores last deleted undo and clears lastDeletedUndo field',
        build: buildBloc,
        seed: () => TodosOverviewState(lastDeletedTodo: mockTodos.first),
        act: (bloc) => bloc.add(const TodosOverviewUndoDeletionRequested()),
        expect: () => const [TodosOverviewState()],
        verify: (_) {
          verify(() => todosRepository.updateTodo(mockTodos.first)).called(1);
        },
      );
    });

    group('TodosOverviewFilterChanged', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'emits state with updated filter',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const TodosOverviewFilterChanged(TodosViewFilter.completedOnly),
        ),
        expect: () => const [
          TodosOverviewState(filter: TodosViewFilter.completedOnly),
        ],
      );
    });

    group('TodosOverviewToggleAllRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'toggles all todos to completed when some or none are uncompleted',
        setUp: () {
          when(
            () => todosRepository.completeAll(),
          ).thenAnswer((_) async => 0);
        },
        build: buildBloc,
        seed: () => TodosOverviewState(todos: mockTodos),
        act: (bloc) => bloc.add(const TodosOverviewToggleAllRequested()),
        verify: (_) {
          verify(
            () => todosRepository.completeAll(),
          ).called(1);
        },
      );

      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'toggles all todos to uncompleted when all are completed',
        setUp: () {
          when(
            () => todosRepository.completeAll(),
          ).thenAnswer((_) async => 0);
        },
        build: buildBloc,
        seed: () => TodosOverviewState(
          todos:
              mockTodos.map((todo) => todo.copyWith(isComplete: true)).toList(),
        ),
        act: (bloc) => bloc.add(const TodosOverviewToggleAllRequested()),
        verify: (_) {
          verify(
            () => todosRepository.completeAll(),
          ).called(1);
        },
      );
    });

    group('TodosOverviewClearCompletedRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'clears completed todos using repository',
        setUp: () {
          when(
            () => todosRepository.clearCompleted(),
          ).thenAnswer((_) async => 0);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewClearCompletedRequested()),
        verify: (_) {
          verify(() => todosRepository.clearCompleted()).called(1);
        },
      );
    });
  });
}
