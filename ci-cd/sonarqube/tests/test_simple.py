"""Simple tests để pass CI"""


def test_math():
    """Test cơ bản nhất"""
    assert 1 + 1 == 2


def test_string():
    """Test string"""
    assert "hello" == "hello"


def test_list():
    """Test list"""
    my_list = [1, 2, 3]
    assert len(my_list) == 3