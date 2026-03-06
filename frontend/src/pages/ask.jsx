import React, { useState } from "react";
import "./ask.css";

const Ask = () => {
  const [subject, setSubject] = useState("");
  const [difficulty, setDifficulty] = useState("");
  const [progress, setProgress] = useState("");
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [role, setRole] = useState("student"); // 新增：提问者身份，默认为"学生"
  const [message, setMessage] = useState("");

  // 学科到标签 ID 的映射
  const subjectToTagId = {
    math: 1,      // 数学
    english: 2,   // 英语
    programming: 3, // 编程语言
    physics: 4,   // 物理
    chemistry: 5, // 化学
    biology: 6,   // 生物
    programmingComputer: 7, // 编程与计算机
    economics: 8, // 经管/社科
    engineering: 9, // 电子与工程
    englishAcademic: 10,   // 英语与学术写作
    research: 11,  // 科研
    other: 12,     // 其他
  };

  // 难度到标签 ID 的映射
  const difficultyToTagId = {
    easy: 13,      // 简单
    medium: 14,    // 中等
    hard: 15,      // 偏难
    expert: 16,    // 极难
  };

  // 进度到标签 ID 的映射
  const progressToTagId = {
    start: 17,     // 开始
    middle: 18,   // 中程
    end: 19,      // 末尾
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMessage("发布中...");

    const token = localStorage.getItem("token");
    if (!token) {
      setMessage("请先登录");
      return;
    }

    // 将选择的选项转换为标签 ID
    const tagIds = [];
    if (subject) tagIds.push(subjectToTagId[subject]);
    if (difficulty) tagIds.push(difficultyToTagId[difficulty]);
    if (progress) tagIds.push(progressToTagId[progress]);

    try {
      const response = await fetch("/api/questions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          title,
          content,
          tagIds,
          role, // 包含提问者身份
        }),
      });

      const data = await response.json();

      if (response.ok) {
        setMessage("发布成功!");
        setTimeout(() => {
          setTitle("");
          setContent("");
          setSubject("");
          setDifficulty("");
          setProgress("");
          setMessage("");
        }, 2000);
      } else {
        setMessage(data.message || "发布失败");
      }
    } catch (error) {
      setMessage("服务器错误,请稍后重试");
      console.error("Error:", error);
    }
  };

  return (
    <div className="ask-container">
      <div className="ask-content">
        <h1 className="ask-title">提问</h1>

        <form className="ask-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label">提问者身份</label>
            <select
              className="form-select"
              value={role}
              onChange={(e) => setRole(e.target.value)}
              required
            >
              <option value="student">学生</option>
              <option value="teacher">老师</option>
            </select>
          </div>

          <div className="form-group">
            <label className="form-label">学科</label>
            <select
              className="form-select"
              value={subject}
              onChange={(e) => setSubject(e.target.value)}
              required
            >
              <option value="">请选择学科</option>
              <option value="math">数学</option>
              <option value="english">英语</option>
              <option value="programming">编程语言</option>
              <option value="physics">物理</option>
              <option value="chemistry">化学</option>
              <option value="biology">生物</option>
              <option value="programmingComputer">编程与计算机</option>
              <option value="economics">经管/社科</option>
              <option value="engineering">电子与工程</option>
              <option value="englishAcademic">英语与学术写作</option>
              <option value="research">科研</option>
              <option value="other">其他</option>
            </select>
          </div>

          <div className="form-group">
            <label className="form-label">难度</label>
            <select
              className="form-select"
              value={difficulty}
              onChange={(e) => setDifficulty(e.target.value)}
              required
            >
              <option value="">请选择难度</option>
              <option value="easy">简单</option>
              <option value="medium">中等</option>
              <option value="hard">偏难</option>
              <option value="expert">极难</option>
            </select>
          </div>

          <div className="form-group">
            <label className="form-label">进度</label>
            <select
              className="form-select"
              value={progress}
              onChange={(e) => setProgress(e.target.value)}
              required
            >
              <option value="">请选择进度</option>
              <option value="start">开始</option>
              <option value="middle">中程</option>
              <option value="end">末尾</option>
            </select>
          </div>

          <div className="form-group">
            <label className="form-label">标题</label>
            <input
              type="text"
              className="form-input"
              placeholder="输入标题"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
            />
          </div>

          <div className="form-group">
            <label className="form-label">疑问</label>
            <textarea
              className="form-textarea"
              placeholder="请输入"
              value={content}
              onChange={(e) => setContent(e.target.value)}
              required
              rows="8"
            />
          </div>

          {message && <p className="message">{message}</p>}

          <button type="submit" className="submit-btn">
            发布
          </button>
        </form>
      </div>
    </div>
  );
};

export default Ask;